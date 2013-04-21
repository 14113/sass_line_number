require "sass_line_number/version"

module SassLineNumber
  class Sass::Tree::Visitors::ToCss < Sass::Tree::Visitors::Base
  protected

    def visit_rule(node)
      with_tabs(@tabs + node.tabs) do
        rule_separator = node.style == :compressed ? ',' : ', '
        line_separator =
          case node.style
            when :nested, :expanded; "\n"
            when :compressed; ""
            else; " "
          end
        rule_indent = '  ' * @tabs
        per_rule_indent, total_indent = [:nested, :expanded].include?(node.style) ? [rule_indent, ''] : ['', rule_indent]

        joined_rules = node.resolved_rules.members.map do |seq|
          next if seq.has_placeholder?
          rule_part = seq.to_a.join
          if node.style == :compressed
            rule_part.gsub!(/([^,])\s*\n\s*/m, '\1 ')
            rule_part.gsub!(/\s*([,+>])\s*/m, '\1')
            rule_part.strip!
          end
          rule_part
        end.compact.join(rule_separator)

        joined_rules.sub!(/\A\s*/, per_rule_indent)
        joined_rules.gsub!(/\s*\n\s*/, "#{line_separator}#{per_rule_indent}")
        total_rule = total_indent << joined_rules

        to_return = ''
        old_spaces = '  ' * @tabs
        spaces = '  ' * (@tabs + 1)
        if node.style != :compressed
          if node.options[:debug_info] && !@in_directive
            to_return << visit(debug_info_rule(node.debug_info, node.options)) << "\n"
          elsif node.options[:trace_selectors]
            to_return << "#{old_spaces}/* "
            to_return << node.stack_trace.join("\n   #{old_spaces}")
            to_return << " */\n"
          elsif node.options[:line_comments]
            to_return << "#{old_spaces}/* line #{node.line}"

            if node.filename
              relative_filename = if node.options[:css_filename]
                begin
                  Pathname.new(node.filename).relative_path_from(
                    Pathname.new(File.dirname(node.options[:css_filename]))).to_s
                rescue ArgumentError
                  nil
                end
              end
              relative_filename ||= node.filename
              to_return << ", #{relative_filename}:#{node.line}"
            end

            to_return << " */\n"
          end
        end

        if node.style == :compact
          properties = with_tabs(0) {node.children.map {|a| visit(a)}.join(' ')}
          to_return << "#{total_rule} { #{properties} }#{"\n" if node.group_end}"
        elsif node.style == :compressed
          properties = with_tabs(0) {node.children.map {|a| visit(a)}.join(';')}
          to_return << "#{total_rule}{#{properties}}"
        else
          properties = with_tabs(@tabs + 1) {node.children.map {|a| visit(a)}.join("\n")}
          end_props = (node.style == :expanded ? "\n" + old_spaces : ' ')
          to_return << "#{total_rule} {\n#{properties}#{end_props}}#{"\n" if node.group_end}"
        end

        to_return
      end
    end
  end
end
