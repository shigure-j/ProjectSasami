class Format < ApplicationRecord
  belongs_to :stage, optional: true

  def format_of(cate)
    n_fmt = JSON.parse(self.format)[cate]
    n_fmt.keys.map do |key|
      value = n_fmt[key] || {}
      [key, 
        {
          formatter:  "window.cellFormatter('#{value["type"]}', '#{value["option"]}')",
          width:      value["width"]
        }
      ]
    end.to_h
  end

  def all_categories
    JSON.parse(self.format).keys
  end

  def init_format_by(data_content)
    self.format = data_content.to_a.map do |cate|
                    key, value = cate
                    [ key,
                      value.map(&:keys).reduce(&:concat).uniq.
                        map {|i| [i, nil]}.to_h
                    ]
                  end.to_h.to_json
  end
end
