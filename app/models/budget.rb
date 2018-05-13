class Budget < ActiveRecord::Base
  belongs_to :page

  #
  # Validations
  #
  validates :category, presence: true
  validates :item, presence: true
  validates :budget, presence: true
  validates :page, presence: true

  def as_json(options={})
    super({only: [:id, :category, :item, :budget, :created_at, :updated_at]}.merge(options || {}))
  end
end
