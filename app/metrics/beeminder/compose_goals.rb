PROVIDERS.fetch(:beeminder).register_metric :compose_goals do |metric|
  metric.description = "Compose multiple goals into one by providing a factor for each goal. Each datapoint from a source goal will be multiplied by the factor provided and sent to target goal."
  metric.title = "Compose goals"
  slug_key = "source_slugs"

  metric.block = proc do |adapter, options|
    Array(options[slug_key]).flat_map do |slug, factor|
      next [] if factor.blank?
      adapter.recent_datapoints(slug).map do |dp|
        [dp.timestamp.utc, dp.value * Float(factor) ]
      end
    end.group_by(&:first).map do |ts, values|
      Datapoint.new(
        unique: true,
        timestamp: ts,
        value: values.map(&:second).sum
      )
    end
  end

  metric.param_errors = proc do |params|
    slugs = params[slug_key]
    unless slugs.is_a?(Hash)
      ["Must provide #{slug_key} hash"]
    else
      errors = []

      valid_factors = slugs.values.reject(&:blank?).all? do |factor|
        Float(factor) rescue false
      end
      valid_slugs =  slugs.keys.all? do |key|
        key.is_a?(String) && key.length < 20
      end

      unless valid_factors
        errors << "All factors must be numbers"
        p params
      end

      unless valid_slugs
        errors << "Invalid slug"
      end

      errors
    end
  end
end
