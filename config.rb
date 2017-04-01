# --------------------------------------
#   Config
# --------------------------------------

# ----- Site ----- #
# Last version should be the latest English version since the manifesto is first 
# written in English, then translated into other languages later.
$last_version = (Dir.entries("source/en") - %w[. ..]).last

# This list of languages populates the language navigation.
issues_url = 'https://github.com/olivierlacan/keep-a-changelog/issues'
$languages = {
  "cs"    => { 
    name: "Čeština", 
    notice: "" 
  },
  "de"    => { 
    name: "Deutsch", 
    notice: "Die neuste version (#{$last_version}) ist noch nicht auf Deutsch
    verfügbar, aber du kannst sie dir <a href='/en/'>auf Englisch durchlesen</a>
    und <a href='#{issues_url}'>bei der Übersetzung mithelfen</a>."
  },
  "en"    => { 
    name: "English", 
    notice: ""
  },
  "es-ES" => { 
    name: "Español", 
    notice: "Aún no está disponible la última versión (#{$last_version}) en
    español, pero por ahora puedes <a href='/en/'>leerla en inglés</a> y <a
    href='#{issues_url}'>ayudar a traducirla</a>."
  },
  "fr"    => { 
    name: "Français", 
    notice: "La dernière version (#{$last_version}) n'est pas encore disponible
    en français, mais vous pouvez la <a href='/en/'>lire en anglais</a> pour
    l'instant et <a href='#{issues_url}'>aider à la traduire</a>."
  },
  "it-IT" => { 
    name: "Italiano", 
    notice: "L'ultima versione (#{$last_version}) non è ancora disponibile in
    Italiano, ma la potete <a href='/en/'>leggere in Inglese</a> per ora e
    potete <a href='#{issues_url}'>contribuire a tradurla</a>."
  },
  "pt-BR" => { 
    name: "Brazilian Portugese", 
    notice: "A última versão (#{$last_version}) ainda não está disponível em 
    Português mas nesse momento você pode <a href='/en/'>lê-la em inglês</a> e 
    <a href='#{issues_url}'>ajudar em sua tradução</a>." 
  },
  "ru"    => { 
    name: "Pyccкий", 
    notice: "Самая последняя версия (#{$last_version}) ещё пока не переведена на
    русский, но вы можете <a href='/en/'>прочитать её на английском</a> и <a
    href='#{issues_url}'>помочь с переводом</a>."
  },
  "sl"    => { 
    name: "Slovenščina", 
    notice: "" 
  },
  "sv"    => { 
    name: "Svenska", 
    notice: "Den senaste versionen (#{$last_version}) är ännu inte tillgänglig på Svenska,
    men du kan <a href='/en/'>läsa det på engelska</a> och även <a
    href='#{issues_url}'>hjälpa till att översätta det</a>."
  },
  "tr-TR" => { 
    name: "Türkçe", 
    notice: "" 
  },
  "zh-CN" => { 
    name: "简体中文", 
    notice: "" 
  },
  "zh-TW" => { 
    name: "繁體中文", 
    notice: "" 
  }
}

activate :i18n,
  lang_map: $languages,
  mount_at_root: :en

set :gauges_id, ''
set :publisher_url, 'https://www.facebook.com/olivier.lacan.5'
set :site_url, 'http://keepachangelog.com'

redirect "index.html", to: "en/#{$last_version}/index.html"

$languages.each do |language|
  code = language.first
  versions = Dir.entries("source/#{code}") - %w[. ..]
  redirect "#{code}/index.html", to: "#{code}/#{versions.last}/index.html"
end

# ----- Assets ----- #

set :css_dir, 'assets/stylesheets'
set :js_dir, 'assets/javascripts'
set :images_dir, 'assets/images'
set :fonts_dir, 'assets/fonts'

# ----- Images ----- #

activate :automatic_image_sizes

# ----- Markdown ----- #

activate :syntax
set :markdown_engine, :redcarpet

## Override default Redcarpet renderer in order to define a class 
class CustomMarkdownRenderer < Redcarpet::Render::HTML
  def header(text, header_level)
    slug = text.gsub(" ", "-").downcase
    tag_name = "h#{header_level}"
    anchor_link = "<a id='#{slug}' class='anchor' href='##{slug}' aria-hidden='true'></a>"
    header_tag_open = "<#{tag_name} id='#{slug}'>"

    output = ""
    output << header_tag_open
    output << anchor_link
    output << text
    output << "</#{tag_name}>"

    output
  end
end

$markdown_config = {
  fenced_code_blocks: true,
  footnotes: true,
  smartypants: true,
  tables: true,
  with_toc_data: true,
  renderer: CustomMarkdownRenderer
}
set :markdown, $markdown_config

# --------------------------------------
#   Helpers
# --------------------------------------

helpers do
  def path_to_url(path)
    Addressable::URI.join(config.site_url, path).normalize.to_s
  end
end

# --------------------------------------
#   Content
# --------------------------------------

# ----- Directories ----- #

activate :directory_indexes
page "/404.html", directory_index: false

# --------------------------------------
#   Production
# --------------------------------------

# ----- Optimization ----- #

configure :build do
  set :gauges_id, "5389808eeddd5b055a00440d"
  activate :asset_hash
  activate :gzip, {exts: %w[
    .css
    .eot
    .htm
    .html
    .ico
    .js
    .json
    .svg
    .ttf
    .txt
    .woff
  ]}
  set :haml, {ugly: true, attr_wrapper: '"'}
  activate :minify_css
  activate :minify_html do |html|
    html.remove_quotes = false
  end
  activate :minify_javascript
end

# ----- Prefixing ----- #

activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'Explorer >= 10']
  config.cascade  = false
end

# Haml doesn't pick up on Markdown configuration so we have to remove the 
# default Markdown Haml filter and reconfigure one that follows our 
# global configuration.

module Haml::Filters
  remove_filter("Markdown") #remove the existing Markdown filter

  module Markdown
    include Haml::Filters::Base

    def renderer
      $markdown_config[:renderer]
    end

    def render(text)
      Redcarpet::Markdown.new(renderer.new($markdown_config)).render(text)
    end
  end
end