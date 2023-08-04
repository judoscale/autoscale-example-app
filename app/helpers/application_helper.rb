module ApplicationHelper
  def latency_opts
    {
      1000 => "1 sec",
      5000 => "5 sec",
      10_000 => "10 sec",
      25_000 => "25 sec"
    }
  end

  def jobs_opts
    {
      1 => "1 job",
      5 => "5 jobs",
      10 => "10 jobs",
      50 => "50 jobs"
    }
  end

  def queue_opts
    %w[default urgent]
  end

  def field(&block)
    tag.div capture(&block)
  end

  def label(text)
    tag.p text, class: "prose mb-4"
  end

  def radio_buttons(form, name, choices)
    tag.div class: "flex gap-8" do
      choices.map do |value, label|
        tag.label class: "flex items-center gap-2" do
          concat form.radio_button name, value, class: "focus:ring-indigo-500 h-4 w-4 text-indigo-600 border-gray-300"
          concat tag.span label || value, class: "text-sm font-medium text-gray-700"
        end
      end.join.html_safe
    end
  end

  def button_row(label)
    tag.div do
      button_tag label, class: "bg-indigo-600 border border-transparent rounded-md shadow-sm py-2 px-4 inline-flex justify-center text-sm font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-600"
    end
  end
end
