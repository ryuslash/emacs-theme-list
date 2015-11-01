module Themes
  class ThemePage < Jekyll::Page
    def initialize(site, base, dir, theme, modes, prev_theme, next_theme)
      @site = site
      @base = base
      @dir = dir
      @name = "#{theme}.html"

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'theme.html')

      data['title'] = theme
      data['modes'] = modes

      data['next'] = "#{next_theme}.html"
      data['previous'] = "#{prev_theme}.html"
    end
  end

  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      dir = site.config['theme_dir'] || 'themes'
      themes = gather_themes(site)

      themes.keys.each_with_index do |theme, idx|
        modes = themes[theme]
        site.pages << ThemePage.new(site, site.source, dir, theme, modes,
                                    themes.keys[idx - 1],
                                    themes.keys[(idx + 1) % themes.size])
      end
    end

    def gather_themes(site)
      site.static_files.each_with_object({}) do |e, a|
        regexp = %r{\A/screenshots/(.*?)/(.*?).png\z}
        match = regexp.match(e.relative_path)

        if match
          a[match[1]] = [] if a[match[1]].nil?
          a[match[1]] << match[2]
        end
      end
    end
  end
end
