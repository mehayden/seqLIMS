module FkFinders
  extend ActiveSupport::Concern

# map model names to forign key fields that reference them
# this could be done with reflections, but for simplicity
# and efficiency we specify the ones we care about here
=begin
ModelToForeignKeyFields = {
  'Patient' => ['patient_id'],
  'Sample' => ['sample_id', 'source_sample_id']
}
=end

# map foreign key fields to model names they reference
ForeignKeyFieldToModels = {
  'patient_id' => 'Patient',
  'sample_id' => 'Sample',
  'source_sample_id' => 'Sample'
}

# these should match the keys used in the finder methods defined below
=begin
FinderKeys = {
  'Patient' => ['mrn'],
  'Sample' => ['barcode']
}
=end

# Methods in this module have names that can be constructed from the following parts:
#  fk_find_ - prefix
#  <singular_table_name>_ - of the table we are finding from
#  <key> - to represent the thing we are searching by

  def fk_find_patient_mrn(mrn)
    id, added = Patient.get_patient_id(mrn)
    return id
  end

  def fk_find_sample_barcode(barcode)
    sample = Sample.find_by_barcode_key(barcode)
    return nil if sample.nil?
    return sample.id
  end

=begin
  # takes a model and returns a hash of possible
  # header names indicating that there is a foreign key finder available
  def fk_finders_map(model)
    map = {}
#    models.each do |model|
      fk_fields = ModelToForeignKeyFields[model.name]
      return if fk_fields.nil?
      fk_fields.each do |fkf|
        keys = FinderKeys[model.name]
        break if keys.nil?
        keys.each do |key|
          # construct the header name to be used
          header = fkf + '.' + key 
          stn = model.name.tableize.singularize
          method = ('fk_find_' + stn + '_' + key).to_sym
#logger.debug "fk_finders_map: header: #{header} method: #{method}"
          if self.respond_to?(method)
            map[header] = method
          else
            raise "No foreign key finder method defined for model #{model.name}, key #{key}"
          end
        end
      end
#    end
logger.debug "fk_finders_map: #{map.inspect}"
    return map
  end
=end

  # return the real attribute name to assign the found id to
  def fk_finder_real_attr(name)
    name.split('.').first
  end

end

