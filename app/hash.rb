# frozen_string_literal: true

class Hash
  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def symbolize_keys
    deep_transform_keys dup, &:to_sym
  end

  private

  def deep_transform_keys(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = deep_transform_keys(value, &block)
      end
    when Array
      object.map { |e| deep_transform_keys(e, &block) }
    else
      object
    end
  end
end
