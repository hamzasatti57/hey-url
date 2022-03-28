# frozen_string_literal: true

class Url < ApplicationRecord
  has_many :clicks, dependent: :destroy
end
