require 'csv'

project = Project.find(4)
modelJob = project.model_jobs.where(:project_version => project.version).last

permeabilityValues = ActiveSupport::JSON.decode(modelJob.output)

segments = project.segments

total = segments.length
firstQuarter = (total * 0.25).floor
secondQuarter = (total * 0.5).floor

synthesizedData = []

highestPermeability = 0

segments[0..firstQuarter].each do |s|
  pv = permeabilityValues.reject {|pv| pv['segment_id'] != s.id }
  pv = pv.first
  
  synthesizedCount = pv['permeability'].floor
  
  if synthesizedCount > highestPermeability
    highestPermeability = synthesizedCount
  end
  
  cs = CountSession.create(
    :segment => s,
    :project => project,
    :start => Time.now,
    :stop => Time.now,
    :count_total => synthesizedCount
  )
    
  # synthesizedCount.times do |i|
  #   cs.counts.create(:at => Time.now)
  # end
  
  sd = Hash.new
  sd['segment_id'] = s.id
  sd['permeability'] = pv['permeability']
  sd['count_total'] = synthesizedCount
  sd['kind'] = 'permeability'
  
  synthesizedData.push(sd)
end

segments[(firstQuarter + 1)..secondQuarter].each do |s|
  pv = permeabilityValues.reject {|pv| pv['segment_id'] != s.id }
  pv = pv.first
  
  randomCount = rand(highestPermeability)
  
  cs = CountSession.create(
    :segment => s,
    :project => project,
    :start => Time.now,
    :stop => Time.now,
    :count_total => randomCount
  )
  
  # randomCount.times do |i|
  #   cs.counts.create(:at => Time.now)
  # end
  
  sd = Hash.new
  sd['segment_id'] = s.id
  sd['permeability'] = pv['permeability']
  sd['count_total'] = randomCount
  sd['kind'] = 'random'
  
  synthesizedData.push(sd)
end

segments[(secondQuarter + 1)..(total - 1)].each do |s|
  pv = permeabilityValues.reject {|pv| pv['segment_id'] != s.id }
  pv = pv.first
  
  sd = Hash.new
  sd['segment_id'] = s.id
  sd['permeability'] = pv['permeability']
  sd['count_total'] = 0
  sd['kind'] = 'noChange'
  
  synthesizedData.push(sd)
end

CSV.open("synthesized_data" + Time.new.strftime("%e%b%Y") + ".csv", "w") do |csv|
  csv << ["segment_id", "permeability", "count_total", "kind"]
  synthesizedData.each do |sd|
    csv << [sd['segment_id'], sd['permeability'], sd['count_total'], sd['kind']]
  end
end