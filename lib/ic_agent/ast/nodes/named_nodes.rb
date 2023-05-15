require 'treetop'

module IcAgent
  module Ast
    module Nodes
      class NamedNode < Treetop::Runtime::SyntaxNode
        def title
          :named_node
        end

        def to_array
          [title] + elements.map(&:to_array)
        end

        def to_s
          "#{title.to_s.upcase} #{elements_to_s}"
        end

        def elements_to_s
          elements.map(&:to_s).join("\n")
        end
      end

      class Instruction < NamedNode
        def title; :instruction end

        def to_s
          elements_to_s
        end
      end

      class Comment < NamedNode
        def title; :comment end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class DIDFile < NamedNode
        def title; :did_file end

        def to_s
          elements_to_s
        end
      end

      class Service < NamedNode
        def title; :dockerfile end

        def to_s
          elements_to_s
        end
      end

      class IcServiceName < NamedNode
        def title
          :ic_service_name
        end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class IcServiceMethods < NamedNode
        def title
          :ic_service_name
        end

        def value
          elements.map { |update| update.value }
        end
      end

      class IcServiceMethodName < NamedNode
        def title
          :ic_service_method_name
        end
      end

      class IcServiceItem < NamedNode
        def title; :dockerfile end

        def to_s
          elements_to_s
        end
      end

      class IcServiceParam < NamedNode
        def title; :ic_service_param end

        def to_s
          "# #{elements[0].to_s}"
        end
      end

      class IcServiceName < NamedNode
        def title; :ic_service_name end

        def to_s
          "# #{elements[0].to_s}"
        end
      end
    end
  end
end

