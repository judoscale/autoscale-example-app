class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def field(&block)
    @template.tag.div @template.capture(&block)
  end

  def label(text)
    @template.tag.p text, class: "prose mb-4"
  end

  def radio_buttons(name, choices)
    @template.tag.div class: "flex gap-8" do
      choices.map do |value, label|
        @template.tag.label class: "flex items-center gap-2" do
          @template.concat radio_button(name, value, class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300")
          @template.concat @template.tag.span(label || value, class: "text-sm font-medium text-gray-700")
        end
      end.join.html_safe
    end
  end

  def button_row(label)
    @template.tag.div do
      button label, class: "bg-indigo-600 border border-transparent rounded-md shadow-sm py-2 px-4 inline-flex justify-center text-sm font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-600"
    end
  end
end
