require 'crawler_rocks'
require 'json'
require 'pry'

class UtaipeiCourseCrawler

	def initialize year: nil, term: nil, update_progress: nil, after_each: nil

		@year = year
		@term = term
		@update_progress_proc = update_progress
		@after_each_proc = after_each
	end

	def courses 

		@courses = []

		first_time_list = ['ZZ40', '2410', 'XC00', '9711', '9747', '7100', '5700', '9200']		#for load page

		query_url = %x(curl -s 'http://210.71.24.139/utaipei/ag_pro/ag304_face.jsp?uid=null' --compressed)
		doc = Nokogiri::HTML(query_url)

		#find department's id
		select = doc.css('select')[1]	
		option_times = select.css('option').count
		for i in 1..option_times
			#select department
			dep_id = query_url.split('select id')[2].split('value=')[i][1..2]
			unt_id = first_time_list[i - 1]
			temp_url = %x(curl -s 'http://210.71.24.139/utaipei/ag_pro/ag304_face.jsp' --data 'yms_yms=#{@year-1911}%23#{@term}&dpt_id=#{dep_id}&unt_id=#{unt_id}&data=%E5%90%84%E5%A4%A7%E6%A8%93%E4%BB%A3%E7%A2%BC%E8%AA%AA%E6%98%8E%E8%A1%A8%3CHR%3E%3Ctable+border%3D0+width%3D97%25+align%3Dcenter%3E%3Ctr%3E%3Ctd%3E%E8%A1%8C%E6%94%BF%E5%A4%A7%E6%A8%93-C%2810%29%3C%2Ftd%3E%3Ctd%3E%E9%B4%BB%E5%9D%A6%E6%A8%93-B%2811%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E7%A7%91%E8%B3%87%E5%A4%A7%E6%A8%93-D%2812%29%3C%2Ftd%3E%3Ctd%3E%E8%A9%A9%E6%AC%A3%E9%A4%A8-E%2813%29%3C%2Ftd%3E%3Ctd%3E%E9%AB%94%E8%82%B2%E9%A4%A8-A%2814%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E6%A0%A1%E5%A4%96%E5%A0%B4%E5%9C%B0%2815%29%3C%2Ftd%3E%3Ctd%3E%E5%AE%A4%E5%A4%96%E5%85%B6%E4%BB%96%E8%A1%93%E7%A7%91%E5%A0%B4%E5%9C%B0%288%29%3C%2Ftd%3E%3Ctd%3E%E8%97%9D%E8%A1%93%E9%A4%A8%28A%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E4%B8%AD%E6%AD%A3%E5%A0%82%28B%29%3C%2Ftd%3E%3Ctd%3E%E5%8B%A4%E6%A8%B8%E6%A8%93%28C%29%3C%2Ftd%3E%3Ctd%3E%E5%85%AC%E8%AA%A0%E6%A8%93%28G%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E5%9C%96%E6%9B%B8%E9%A4%A8%28L%29%3C%2Ftd%3E%3Ctd%3E%E9%9F%B3%E6%A8%82%E9%A4%A8%28M%29%3C%2Ftd%3E%3Ctd%3E%E5%AD%B8%E7%94%9F%E5%AE%BF%E8%88%8D%28R%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E7%A7%91%E5%AD%B8%E9%A4%A8%28S%29%3C%2Ftd%3E%3Ctd%3E%E8%A1%8C%E6%94%BF%E5%A4%A7%E6%A8%93%28%E5%8D%9A%E6%84%9B%E6%A0%A1%E5%8D%80%29%28T%29%3C%2Ftd%3E%3Ctd%3E%E5%85%B6%E5%AE%83%28%E5%8D%9A%E6%84%9B%E6%A0%A1%E5%8D%80%29%28X%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E6%93%8D%E5%A0%B4%28%E5%8D%9A%E6%84%9B%E6%A0%A1%E5%8D%80%29%28Y%29%3C%2Ftd%3E%3C%2Ftr%3E%3C%2Ftable%3E&ls_year=#{@year-1911}&ls_sms=#{@term}&uid=null' --compressed)

			#find unit's id
			option_times2 = temp_url.split('select id')[3].split('value').count - 9 
			for j in 1..option_times2
				#select unit
				unt_id = temp_url.split('select id')[3].split('value')[j][2..5]
				temp_url2 = %x(curl -s 'http://210.71.24.139/utaipei/ag_pro/ag304_02.jsp' --data 'yms_yms=#{@year-1911}%23#{@term}&dpt_id=#{dep_id}&unt_id=#{unt_id}&data=%E5%90%84%E5%A4%A7%E6%A8%93%E4%BB%A3%E7%A2%BC%E8%AA%AA%E6%98%8E%E8%A1%A8%3CHR%3E%3Ctable+border%3D0+width%3D97%25+align%3Dcenter%3E%3Ctr%3E%3Ctd%3E%E8%A1%8C%E6%94%BF%E5%A4%A7%E6%A8%93-C%2810%29%3C%2Ftd%3E%3Ctd%3E%E9%B4%BB%E5%9D%A6%E6%A8%93-B%2811%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E7%A7%91%E8%B3%87%E5%A4%A7%E6%A8%93-D%2812%29%3C%2Ftd%3E%3Ctd%3E%E8%A9%A9%E6%AC%A3%E9%A4%A8-E%2813%29%3C%2Ftd%3E%3Ctd%3E%E9%AB%94%E8%82%B2%E9%A4%A8-A%2814%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E6%A0%A1%E5%A4%96%E5%A0%B4%E5%9C%B0%2815%29%3C%2Ftd%3E%3Ctd%3E%E5%AE%A4%E5%A4%96%E5%85%B6%E4%BB%96%E8%A1%93%E7%A7%91%E5%A0%B4%E5%9C%B0%288%29%3C%2Ftd%3E%3Ctd%3E%E8%97%9D%E8%A1%93%E9%A4%A8%28A%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E4%B8%AD%E6%AD%A3%E5%A0%82%28B%29%3C%2Ftd%3E%3Ctd%3E%E5%8B%A4%E6%A8%B8%E6%A8%93%28C%29%3C%2Ftd%3E%3Ctd%3E%E5%85%AC%E8%AA%A0%E6%A8%93%28G%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E5%9C%96%E6%9B%B8%E9%A4%A8%28L%29%3C%2Ftd%3E%3Ctd%3E%E9%9F%B3%E6%A8%82%E9%A4%A8%28M%29%3C%2Ftd%3E%3Ctd%3E%E5%AD%B8%E7%94%9F%E5%AE%BF%E8%88%8D%28R%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E7%A7%91%E5%AD%B8%E9%A4%A8%28S%29%3C%2Ftd%3E%3Ctd%3E%E8%A1%8C%E6%94%BF%E5%A4%A7%E6%A8%93%28%E5%8D%9A%E6%84%9B%E6%A0%A1%E5%8D%80%29%28T%29%3C%2Ftd%3E%3Ctd%3E%E5%85%B6%E5%AE%83%28%E5%8D%9A%E6%84%9B%E6%A0%A1%E5%8D%80%29%28X%29%3C%2Ftd%3E%3C%2Ftr%3E%3Ctr%3E%3Ctd%3E%E6%93%8D%E5%A0%B4%28%E5%8D%9A%E6%84%9B%E6%A0%A1%E5%8D%80%29%28Y%29%3C%2Ftd%3E%3C%2Ftr%3E%3C%2Ftable%3E&ls_year=#{@year-1911}&ls_sms=#{@term}&uid=null' --compressed)

				#find department code
				option_times3 = temp_url2.split('go_next').count - 1

				puts j
				if option_times3 > 0 

					for k in 2..option_times3
						#select department code
						department_code = temp_url2.split('go_next')[k][2..9]

						url = %x(curl -s 'http://210.71.24.139/utaipei/ag_pro/ag304_03.jsp' --data 'arg01=#{@year-1911}&arg02=#{@term}&arg=#{department_code}&uid=null' --compressed)
						doc = Nokogiri::HTML(url)

						for tr in 1..(doc.css('table')[0].css('tr').count - 1)

							td = doc.css('table')[0].css('tr')[tr].css('td')

							for other in 0..td[8].text.lines.count - 2		#多位教師

								many_info = td[8].text.lines[other]

								course = {
									year: @year,
									term: @term,
									department: doc.css('font')[1].text,		#班級
									department_code: department_code,		#班級代碼
									general_code: td[0].text,		#選課代碼
									name: td[1].text,		#科目
									group: td[2].text	,	#分組
									credits: td[3].text,		#學分
									hours: td[4].text,		#時數
									required: td[5].text,		#必選修	
									department_term: td[6].text,		#開課別	
									campus: td[7].text,		#校區
									lecturer: many_info.split(' ')[0],		#上課教師
									day_1: (cut_str many_info.split(' ')[1], '(', ')')[0],		#上課日
									day_2: (cut_str many_info.split(' ')[2], '(', ')')[0],
									day_3: (cut_str many_info.split(' ')[3], '(', ')')[0],
									day_4: (cut_str many_info.split(' ')[4], '(', ')')[0],
									day_5: (cut_str many_info.split(' ')[5], '(', ')')[0],
									day_6: (cut_str many_info.split(' ')[6], '(', ')')[0],
									day_7: (cut_str many_info.split(' ')[7], '(', ')')[0],
									period_1: (cut_str many_info.split(' ')[1], '(', ')')[1],		#上課節次
									period_2: (cut_str many_info.split(' ')[2], '(', ')')[1],
									period_3: (cut_str many_info.split(' ')[3], '(', ')')[1],
									period_4: (cut_str many_info.split(' ')[4], '(', ')')[1],
									period_5: (cut_str many_info.split(' ')[5], '(', ')')[1],
									period_6: (cut_str many_info.split(' ')[6], '(', ')')[1],
									period_7: (cut_str many_info.split(' ')[7], '(', ')')[1],
									location_1: (cut_str many_info.split(' ')[1], '(', ')')[2],		#上課教室
									location_2: (cut_str many_info.split(' ')[2], '(', ')')[2],	
									location_3: (cut_str many_info.split(' ')[3], '(', ')')[2],	
									location_4: (cut_str many_info.split(' ')[4], '(', ')')[2],	
									location_5: (cut_str many_info.split(' ')[5], '(', ')')[2],	
									location_6: (cut_str many_info.split(' ')[6], '(', ')')[2],	
									location_7: (cut_str many_info.split(' ')[7], '(', ')')[2],	
									field: td[9].text,		#領域類
									sex_required: td[10].text,		#限制性別
									curriculum: td[11].text	,	#教學綱要
								}
								@after_each_proc.call(course: course) if @after_each_proc
								# binding.pry
								@courses << course
							end
						end
					end
				end
			end
		end

		@courses
	end

	def cut_str a_str, cut_start, cut_end
		# (?<name>[^\(\)\s]{2,}?)(\s\((?<day>[一二三四五])\)(?<period>[\dABCDEFG\-]+)*?\((?<loc>[^\)]+?)\))
		# (\s\((?<day>[一二三四五])\)(?<period>[\dABCDEFG\-]+)*?\((?<loc>[^\)]+?)\))
		@cut_down = []
		cut_num = []

		if not a_str == nil
			for i in 0..a_str.length - 1
				if a_str[i].include?cut_start
					cut_num.push(i)
				elsif a_str[i].include?cut_end
					cut_num.push(i)
				end
			end
		end

		if cut_num.count > 0
			for i in 0..(cut_num.count - 2)
				cut_temp = a_str[(cut_num[i]+1)..(cut_num[i+1]-1)]
				@cut_down.push(cut_temp)
			end
		end

		@cut_down
	end

end

# crawler = UtaipeiCourseCrawler.new(year: 2015, term: 1)
# File.write('courses.json', JSON.pretty_generate(crawler.courses()))
