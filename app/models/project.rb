# == Schema Information
#
# Table name: projects
#
#  id                  :integer          not null, primary key
#  organization_id     :integer
#  name                :string(255)
#  kind                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  southwest_latitude  :decimal(15, 10)
#  southwest_longitude :decimal(15, 10)
#  northeast_latitude  :decimal(15, 10)
#  northeast_longitude :decimal(15, 10)
#  version             :integer
#  max_number_of_gates :integer
#  base_map            :string(255)      default("osm")
#  allowed_to_export   :boolean          default(FALSE)
#
# Indexes
#
#  index_projects_on_organization_id  (organization_id)
#

class Project < ActiveRecord::Base
  belongs_to :organization
  has_many :project_members, :dependent => :destroy
  has_many :users, :through => :project_members
  
  has_many :segments, :dependent => :destroy
  has_many :geo_points, :dependent => :destroy
  has_many :geo_point_on_segments
  has_many :count_plans, :dependent => :destroy
  has_many :count_sessions, :dependent => :destroy
  has_many :scenarios, :dependent => :destroy
  has_many :model_jobs, :dependent => :destroy

  has_many :log_entries
  
  accepts_nested_attributes_for :project_members, :allow_destroy => true

  attribute_choices :kind, 
                    [['pedcount', 'PedCount'], ['pedplus', 'PedPlus']],
                    :validate => true

  validates :name, :presence => true
  validates :organization, :presence => true
  
  after_create :set_allowed_to_export
  def set_allowed_to_export
    if organization.allowed_to_export_projects
      self.update_attribute :allowed_to_export, true
    else
      self.update_attribute :allowed_to_export, false
    end
  end

  def remove_broken_segments
    self.segments.each do |s|
      if s.geo_points.length != 2
        s.destroy()
      end
    end
  end

  def cache_bounding_box
    southwestLatitude = -Float::INFINITY
    southwestLongitude = Float::INFINITY
    northeastLatitude = Float::INFINITY
    northeastLongitude = -Float::INFINITY
    
    geo_points.each do |gp|
      latitude = gp.latitude.to_f
      longitude = gp.longitude.to_f
      if longitude < southwestLongitude
        southwestLongitude = longitude
      end
      if longitude > northeastLongitude
        northeastLongitude = longitude
      end
      if latitude < northeastLatitude
        northeastLatitude = latitude 
      end
      if latitude > southwestLatitude
        southwestLatitude = latitude
      end 
    end
    
    self.update_attributes(
      :southwest_latitude => southwestLatitude,
      :southwest_longitude => southwestLongitude,
      :northeast_latitude => northeastLatitude,
      :northeast_longitude => northeastLongitude
    )
  end

  # used in Api::UsersController
  attr_accessor :current_user
  def permissions_for_current_user
    projectMembership = self.project_members.where(:user_id => current_user.id).first
    return {
      "view" => projectMembership.view,
      "count" => projectMembership.count,
      "plan" => projectMembership.plan,
      "map" => projectMembership.map,
      "manage" => projectMembership.manage
    }
  end
end
