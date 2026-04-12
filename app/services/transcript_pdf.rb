class TranscriptPdf
  def initialize(student, transcript_data)
    @student = student
    @transcript = transcript_data
  end

  def generate
    pdf = Prawn::Document.new(page_size: 'A4', margin: 50)
    pdf.font_families.update('Helvetica' => {
      normal: Rails.root.join('app', 'assets', 'fonts', 'Helvetica.ttf').to_s,
      bold: Rails.root.join('app', 'assets', 'fonts', 'Helvetica-Bold.ttf').to_s
    })
    pdf.font 'Helvetica'

    add_header(pdf)
    add_student_info(pdf)
    add_academic_terms(pdf)
    add_summary(pdf)

    pdf.render
  end

  private

  def add_header(pdf)
    pdf.text 'OFFICIAL TRANSCRIPT', size: 20, style: :bold, align: :center
    pdf.move_down 5
    pdf.text @student.faculty.university.name, size: 14, align: :center
    pdf.text "Generated on: #{Date.current.strftime('%B %d, %Y')}", size: 10, align: :center, color: '666666'
    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20
  end

  def add_student_info(pdf)
    pdf.text 'STUDENT INFORMATION', size: 14, style: :bold
    pdf.move_down 10

    info_data = [
      ['Student Number:', @student.student_number],
      ['Name:', @student.user.full_name],
      ['Faculty:', @student.faculty.name],
      ['Department:', @student.department.name],
      ['Enrollment Date:', @student.enrolled_at.strftime('%B %d, %Y')],
      ['Current GPA:', @transcript[:cumulative_gpa].to_s],
      ['Credit Hours:', @transcript[:credit_hours_completed].to_s],
      ['Academic Standing:', @transcript[:academic_standing].to_s.titleize]
    ]

    info_data.each do |label, value|
      pdf.text "#{label}  #{value}", size: 10
    end

    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 20
  end

  def add_academic_terms(pdf)
    pdf.text 'ACADEMIC HISTORY', size: 14, style: :bold
    pdf.move_down 10

    @transcript[:academic_terms].each do |term_data|
      pdf.text term_data[:term][:name], size: 12, style: :bold
      pdf.text "GPA: #{term_data[:term_gpa]} | Credits: #{term_data[:credit_hours]}", size: 9, color: '333333'
      pdf.move_down 5

      table_data = [['Course Code', 'Course Name', 'Credits', 'Grade']]
      
      term_data[:courses].each do |course|
        table_data << [
          course[:code],
          course[:name],
          course[:credit_hours].to_s,
          course[:grade]
        ]
      end

      pdf.table(table_data, header: true, row_colors: ['F0F0F0', 'FFFFFF']) do
        cells.style(size: 9)
        columns[0].style(width: 80)
        columns[1].style(width: 250)
        columns[2].style(width: 60, align: :center)
        columns[3].style(width: 60, align: :center)
      end

      pdf.move_down 15
    end
  end

  def add_summary(pdf)
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text 'SUMMARY', size: 14, style: :bold
    pdf.move_down 10

    summary_data = [
      ['Cumulative GPA:', @transcript[:cumulative_gpa].to_s],
      ['Total Credit Hours:', @transcript[:credit_hours_completed].to_s],
      ['Academic Standing:', @transcript[:academic_standing].to_s.titleize],
      ['Status:', @student.enrollment_status.to_s.titleize]
    ]

    summary_data.each do |label, value|
      pdf.text "#{label}  #{value}", size: 11, style: :bold
    end

    pdf.move_down 30
    pdf.text 'This is an official document.', size: 9, color: '666666', align: :center
    pdf.text "Document ID: #{@student.student_number}-#{Date.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}", size: 8, color: '999999', align: :center
  end
end
