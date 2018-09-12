require 'action_view'

require 'action_view'
class Cat < ApplicationRecord

    include ActionView::Helpers::DateHelper

    CAT_COLORS = [:black, :white, :orange, :brown]

    validates :color, inclusion: CAT_COLORS
    validates :birthdate, :color, :name, :sex , presence:true

    has_many :rental_requests,
    foreign_key: :cat_id,
    class_name: :CatRentalRequest,
    depndent: :destroy

    def age
        time_ago_in_words(birth_date)
    end

end
