# == Schema Information
#
# Table name: sample_storage_containers
#
#  id                     :integer          not null, primary key
#  stored_sample_id       :integer
#  stored_sample_type     :string(50)
#  sample_name_or_barcode :string(25)       default(""), not null
#  container_type         :string(10)
#  container_name         :string(25)       default(""), not null
#  position_in_container  :string(15)
#  freezer_location_id    :integer
#  storage_container_id   :integer
#  row_nr                 :string(2)
#  position_nr            :string(3)        default("")
#  notes                  :string(100)
#  updated_by             :integer
#  updated_at             :timestamp
#

class SampleStorageContainer < ApplicationRecord
  #belongs_to :freezer_location
  #belongs_to :stored_sample, :polymorphic => true
  # Rails 5 defaults to required: true, so make it explicitly optional
  belongs_to :freezer_location, optional: true
  belongs_to :stored_sample, optional: true, polymorphic: true
  belongs_to :storage_container, optional: true

  before_create :upd_sample_name, :upd_storage_container_fields
  before_update :upd_storage_container_fields

  def upd_sample_name
    self.sample_name_or_barcode = self.stored_sample.barcode_key
  end
  
  def container_desc
    [container_type, container_name].join(': ')
  end

  def container_sort
    (container_name =~ /\A\d\Z/ ? '0' + container_name : container_name)
  end
  
  def container_and_position
    [container_desc, position_in_container].join('/')
  end
  
  def position_sort
    if position_in_container =~ /\A[A-Z]\d+\Z/ 
      sort1 = position_in_container[0,1]
      sort2 = position_in_container[1..-1].to_i
    else
      sort1 = (position_in_container.nil? ? '' : position_in_container)
      sort2 = 0
    end
    return [sort1, sort2] 
  end
  
  def room_and_freezer
    (freezer_location ? freezer_location.room_and_freezer : '')
  end

  def self.find_for_query(condition_array)
    self.includes(:freezer_location).where(sql_where(condition_array))
        .order('freezer_locations.freezer_nr, freezer_locations.room_nr, container_type, container_name').all
  end
  
  def self.populate_dropdown
    self.where('container_type > ""').order(:container_type).uniq.pluck(:container_type)
  end

  # keep redundant fields in sync with the storage container it belongs to
  def upd_storage_container_fields
    if self.storage_container
      self.container_type = self.storage_container.container_type
      self.container_name = self.storage_container.container_name
      self.freezer_location = self.storage_container.freezer_location
    end
  end
end
