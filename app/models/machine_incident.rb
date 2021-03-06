# == Schema Information
#
# Table name: machine_incidents
#
#  id                   :integer          not null, primary key
#  seq_machine_id       :integer
#  incident_date        :date             not null
#  incident_description :string(255)      not null
#  updated_by           :integer
#  created_at           :datetime
#  updated_at           :timestamp
#

class MachineIncident < ApplicationRecord
  belongs_to :seq_machine, optional: true
  
  validates_date :incident_date
end
