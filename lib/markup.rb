module Markup
  
  class Attribute
    def initialize(name, value)
      @name = name
      @value = (value == true ? name.to_s : value)
    end
    
    def to_s
      @name.to_s + '="' + @value + '"'
    end    
  end
  
  class Element
    def initialize(name = nil, attributes = nil, singleton = false, &block)
      if name
        @name = name
        @sigleton = singleton        
        @attributes = attributes.inject(Array.new) { |collection, attribute| collection << Markup::Attribute.new(attribute[0], attribute[1])} if attributes
      end
      
      @contents = (block_given? ? [yield(block)] : [])
    end
    
    def push(element)
      @contents << element
      return self
    end
    
    def inject_into(element)
      element.push(self)
      return self
    end
    
    def attributes_markup
      @attributes.inject(Array.new) { |collection, attribute| collection << attribute.to_s } if @attributes
    end
    
    def open_tag_markup
      [@name.to_s, attributes_markup].compact.join(" ")      
    end
    
    def singleton_markup
      ["<", open_tag_markup, " />"].join
    end
    
    def container_markup
      ["<", open_tag_markup, ">", @contents, "</", @name.to_s, ">"].join
    end
    
    def markup
      @singleton ? singleton_markup : container_markup
    end
    
    def to_s
      @name ? markup : @contents.join
    end
    
  end
  
end