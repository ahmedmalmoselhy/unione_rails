class ScheduleExporter
  def initialize(enrollments)
    @enrollments = enrollments
  end

  def generate_ics
    cal = Icalendar::Calendar.new
    
    # Add timezone
    cal.timezone do |t|
      t.tzid = 'Asia/Riyadh'
      t.standard do |s|
        s.tzoffsetfrom = '+0300'
        s.tzoffsetto = '+0300'
        s.tzname = 'AST'
      end
    end

    @enrollments.each do |enrollment|
      section = enrollment.section
      term = section.academic_term
      schedule = section.schedule

      next if schedule.blank?

      days = schedule['days'] || []
      start_time = schedule['start_time']
      end_time = schedule['end_time']
      location = schedule['location']

      # Create event for each day of the week
      days.each do |day_num|
        # Find first occurrence of this day of week within term
        first_date = find_first_occurrence(term.start_date, day_num)
        
        # Calculate end date based on term duration
        weeks_count = ((term.end_date - term.start_date).to_i / 7).to_i
        
        Icalendar::Event.new(cal) do |e|
          e.summary = "#{section.course.code} - #{section.course.name}"
          e.description = "Professor: #{section.professor.user.full_name}\nSection: #{section.id}"
          e.location = location
          e.dtstart = Icalendar::Values::DateTime.new(
            Time.zone.local(first_date.year, first_date.month, first_date.day) + time_to_seconds(start_time),
            'Asia/Riyadh'
          )
          e.dtend = Icalendar::Values::DateTime.new(
            Time.zone.local(first_date.year, first_date.month, first_date.day) + time_to_seconds(end_time),
            'Asia/Riyadh'
          )
          e.rrule = "FREQ=WEEKLY;COUNT=#{weeks_count}"
          e.uid = "unione-section-#{section.id}-day-#{day_num}"
        end
      end
    end

    cal.to_ical
  end

  private

  def find_first_occurrence(start_date, target_day)
    # target_day: 0=Sunday, 1=Monday, ..., 6=Saturday
    current_date = start_date.to_date
    
    # Find how many days to add to reach target day
    days_to_add = (target_day - current_date.wday) % 7
    
    current_date + days_to_add
  end

  def time_to_seconds(time_str)
    hours, minutes = time_str.split(':').map(&:to_i)
    hours * 3600 + minutes * 60
  end
end
