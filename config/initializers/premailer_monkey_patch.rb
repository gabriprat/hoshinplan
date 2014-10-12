# Patched to no process @media queries in <style> blocks.
# For HTML emails, @media queries are exclusively used for
# targeting mobile clients. These should not be inlined.
class CssParser::Parser
  def parse_block_into_rule_sets!(block, options = {}) # :nodoc:
    current_media_queries = [:all]
    if options[:media_types]
      current_media_queries = options[:media_types].flatten.collect { |mt| CssParser.sanitize_media_query(mt)}
    end

    in_declarations = 0
    block_depth = 0

    in_charset = false # @charset is ignored for now
    in_string = false
    in_at_media_rule = false
    in_media_block = false

    current_selectors = ''
    current_media_query = ''
    current_declarations = ''

    block.scan(/([\\]?[{}\s"]|(.[^\s"{}\\]*))/).each do |matches|
      token = matches[0]

      if token =~ /\A"/ # found un-escaped double quote
        in_string = !in_string
      end       

      if in_declarations > 0
        # too deep, malformed declaration block
        if in_declarations > 1
          in_declarations -= 1 if token =~ /\}/
          next
        end
        
        if token =~ /\{/
          in_declarations += 1
          next
        end
      
        current_declarations += token

        if token =~ /\}/ and not in_string
          current_declarations.gsub!(/\}[\s]*$/, '')
          
          in_declarations -= 1

          unless current_declarations.strip.empty?
            add_rule!(current_selectors, current_declarations, current_media_queries)
          end

          current_selectors = ''
          current_declarations = ''
        end
      elsif token =~ /@media/i
        next # CHANGE ... skip @media
        # found '@media', reset current media_types
        in_at_media_rule = true
        media_types = []
      elsif in_at_media_rule
        if token =~ /\{/
          block_depth = block_depth + 1
          in_at_media_rule = false
          in_media_block = true
          current_media_queries << CssParser.sanitize_media_query(current_media_query)
          current_media_query = ''
        elsif token =~ /[,]/
          # new media query begins
          token.gsub!(/[,]/, ' ')
          current_media_query += token.strip + ' '
          current_media_queries << CssParser.sanitize_media_query(current_media_query)
          current_media_query = ''
        else
          current_media_query += token.strip + ' '
        end
      elsif in_charset or token =~ /@charset/i
        # iterate until we are out of the charset declaration
        in_charset = (token =~ /;/ ? false : true)
      else
        if token =~ /\}/ and not in_string
          block_depth = block_depth - 1

          # reset the current media query scope
          if in_media_block
            current_media_queries = []
            in_media_block = false
          end
        else
          if token =~ /\{/ and not in_string
            current_selectors.gsub!(/^[\s]*/, '')
            current_selectors.gsub!(/[\s]*$/, '')
            in_declarations += 1
          else
            current_selectors += token
          end
        end
      end
    end

    # check for unclosed braces          
    if in_declarations > 0
      add_rule!(current_selectors, current_declarations, current_media_queries)
    end
  end
end