class GoalDecorator < Draper::Decorator
  delegate_all

  def status
    active ? "active" : "disabled"
  end

  def last_score
    score = scores.order(:timestamp).last
    score.nil? ? "none" : score.value
  end

  def beeminder_link(beeminder_user_id)
    h.link_to slug, "https://www.beeminder.com/#{beeminder_user_id}/goals/#{slug}"
  end

  def delete_link
    h.link_to "Delete",
              h.goal_path(self),
              method: :delete,
              "data-confirm": "Are you sure?",
              class: %i(btn btn-default)
  end

  def safe_fetch_scores
    object.fetch_scores
  rescue
    OpenStruct.new timestamp: "now",
                   value: "Could not fetch score"
  end
end
