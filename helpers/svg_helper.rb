require 'lib/svg'

module SvgHelper
  def svg_tag(filename, options={})
    root      = Middleman::Application.root
    file_path = File.join(root, 'source', config[:images_dir], filename)
    return '(SVG img not found)' unless File.exists?(file_path)

    SVG.inline(file_path, options)
  end

  def fa(name)
    return "<i class='fa fa-#{name}' aria-hidden='true'></i>"
  end
end
