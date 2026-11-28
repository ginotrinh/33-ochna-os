//! OCHNA-D7: build COSMIC system defaults for an ochna-aero theme.
//!
//! Usage: ochna-theme <theme-dir> <out-dir>
//! Reads <theme-dir>/theme.ron and writes, under <out-dir>:
//!   share/cosmic/<id>/v<N>/<key>   theme builder, derived theme, mode, toolkit and wallpaper keys
//!   share/backgrounds/ochna/<file> the wallpaper rendered from the spec
//! The derived theme comes from cosmic-theme's own ThemeBuilder::build, so it matches what
//! cosmic-settings would write for the same builder.

use std::{error::Error, fs, path::Path, str::FromStr};

use cosmic_config::{Config, ConfigSet, CosmicConfigEntry};
use cosmic_theme::{
    CornerRadii, LIGHT_THEME_BUILDER_ID, LIGHT_THEME_ID, THEME_MODE_ID, Theme, ThemeBuilder, ThemeMode,
    palette::{Srgb, Srgba},
};
use serde::{Deserialize, Serialize};

#[derive(Deserialize)]
struct Spec {
    accent: String,
    bg_color: String,
    corner_radii: CornerRadii,
    frosted: bool,
    interface_font: String,
    icon_theme: String,
    wallpaper: Wallpaper,
}

#[derive(Deserialize)]
struct Wallpaper {
    file: String,
    width: u32,
    height: u32,
    stops: Vec<(f32, String)>,
    blobs: Vec<Blob>,
}

#[derive(Deserialize)]
struct Blob {
    x: f32,
    y: f32,
    r: f32,
    color: String,
    alpha: f32,
}

// OCHNA-D7: same shape and RON form as libcosmic's FontConfig, without pulling in libcosmic and iced
#[derive(Serialize)]
struct FontConfig<'a> {
    family: &'a str,
    weight: Named,
    stretch: Named,
    style: Named,
}

#[derive(Serialize)]
enum Named {
    Normal,
}

fn rgb(hex: &str) -> Result<Srgb, Box<dyn Error>> {
    Ok(Srgb::<u8>::from_str(hex)?.into_format())
}

fn config(out: &Path, id: &str, version: u64) -> Result<Config, Box<dyn Error>> {
    Ok(Config::with_custom_path(id, version, out.join("share"))?)
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = std::env::args().collect();
    let [_, theme_dir, out] = args.as_slice() else {
        return Err("usage: ochna-theme <theme-dir> <out-dir>".into());
    };
    let (theme_dir, out) = (Path::new(theme_dir), Path::new(out));
    let spec: Spec = ron::from_str(&fs::read_to_string(theme_dir.join("theme.ron"))?)?;

    let mut builder = ThemeBuilder::light()
        .accent(rgb(&spec.accent)?)
        .bg_color(Srgba::from(rgb(&spec.bg_color)?))
        .corner_radii(spec.corner_radii);
    builder.frosted_panel = spec.frosted;
    builder.frosted_applets = spec.frosted;
    builder.frosted_system_interface = spec.frosted;
    let theme: Theme = builder.clone().build();

    builder.write_entry(&config(out, LIGHT_THEME_BUILDER_ID, ThemeBuilder::VERSION)?)?;
    theme.write_entry(&config(out, LIGHT_THEME_ID, Theme::VERSION)?)?;
    ThemeMode { is_dark: false, auto_switch: false }.write_entry(&config(out, THEME_MODE_ID, ThemeMode::VERSION)?)?;

    let tk = config(out, "com.system76.CosmicTk", 1)?;
    tk.set("icon_theme", spec.icon_theme.as_str())?;
    tk.set(
        "interface_font",
        FontConfig { family: &spec.interface_font, weight: Named::Normal, stretch: Named::Normal, style: Named::Normal },
    )?;

    let bg_dir = out.join("share/backgrounds/ochna");
    fs::create_dir_all(&bg_dir)?;
    render(&spec.wallpaper, &bg_dir.join(&spec.wallpaper.file))?;
    // OCHNA-D7: cosmic-bg's BackgroundEntry, written as text to avoid depending on cosmic-bg
    config(out, "com.system76.CosmicBackground", 1)?;
    let entry = format!(
        "(\n    output: \"all\",\n    source: Path(\"/usr/share/backgrounds/ochna/{}\"),\n    filter_by_theme: false,\n    rotation_frequency: 3600,\n    filter_method: Lanczos,\n    scaling_mode: Zoom,\n    sampling_method: Alphanumeric,\n)",
        spec.wallpaper.file
    );
    fs::write(out.join("share/cosmic/com.system76.CosmicBackground/v1/all"), entry)?;
    Ok(())
}

/// Vertical gradient through `stops`, then soft radial blobs blended on top (CSS radial-gradient to
/// transparent at 70% of the radius). Positions and radii are fractions of the image height.
fn render(w: &Wallpaper, path: &Path) -> Result<(), Box<dyn Error>> {
    let stops: Vec<(f32, [f32; 3])> =
        w.stops.iter().map(|(t, c)| rgb(c).map(|c| (*t, [c.red, c.green, c.blue]))).collect::<Result<_, _>>()?;
    let blobs: Vec<(f32, f32, f32, [f32; 3], f32)> = w
        .blobs
        .iter()
        .map(|b| rgb(&b.color).map(|c| (b.x, b.y, b.r, [c.red, c.green, c.blue], b.alpha)))
        .collect::<Result<_, _>>()?;
    let (wd, ht) = (w.width as f32, w.height as f32);
    let mut px = Vec::with_capacity((w.width * w.height * 3) as usize);
    for y in 0..w.height {
        let t = y as f32 / (ht - 1.0);
        let i = stops.iter().rposition(|s| s.0 <= t).unwrap_or(0).min(stops.len() - 2);
        let (a, b) = (stops[i], stops[i + 1]);
        let f = ((t - a.0) / (b.0 - a.0)).clamp(0.0, 1.0);
        let base: [f32; 3] = std::array::from_fn(|k| a.1[k] + (b.1[k] - a.1[k]) * f);
        for x in 0..w.width {
            let mut c = base;
            for (bx, by, br, bc, ba) in &blobs {
                let d = ((x as f32 - bx * wd).powi(2) + (y as f32 - by * ht).powi(2)).sqrt() / (br * ht);
                let alpha = ba * (1.0 - d / 0.7).clamp(0.0, 1.0);
                for k in 0..3 {
                    c[k] = c[k] * (1.0 - alpha) + bc[k] * alpha;
                }
            }
            px.extend(c.map(|v| (v.clamp(0.0, 1.0) * 255.0).round() as u8));
        }
    }
    let mut enc = png::Encoder::new(fs::File::create(path)?, w.width, w.height);
    enc.set_color(png::ColorType::Rgb);
    enc.write_header()?.write_image_data(&px)?;
    Ok(())
}
