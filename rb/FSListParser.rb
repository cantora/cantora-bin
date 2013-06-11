#!/usr/bin/env ruby

require 'optparse'
require 'optparse/time'

require 'rubygems'
require 'rexml/document'
require 'digest/md5'
require 'mysql'
require 'activerecord'

class FSListParser
	
	def self.exception_string(e, msg = "", backtrace=true)
		s = "#{msg}. >>>> #{e.message} (#{e.class})"
		s += "\n#{e.backtrace.join("\n\t")}" if backtrace
		
		return s
	end
			  
	class FSListParserOpts
		def self.parse(args)
			# The options specified on the command line will be collected in *options*.
			# We set default values here.
			options = {:append => false, :db_user => "root", :db_pass => "", :interactive => false, :db => "default_fslist_db"}
			
			opts = OptionParser.new do |opts|
				opts.banner = "Usage: ruby #{__FILE__} [options]"
				opts.separator ""
				opts.separator "Specific options:"
				
				opts.on("-f", "--input-file FILE", "specify the foundation stone file to use as input") do |file|
					options[:file] = file
				end
				
				opts.on("--db DATABASE", "specify the db to use") do |db|
					options[:db] = db
				end
				
				opts.on("-a", "--append", "if a db already exists for this file append instead of replace the db. default: #{options[:append].inspect}") do |append|
					options[:append] = append
				end
				
				opts.on("--srs FILE", "output to an intermediate srs xml file") do |file|
					options[:srs] = file
				end
				
				opts.on("--srs-select QUERY", "select query to supply data for srs file. order: word, translation, gender, plural, type, frequency") do |q|
					options[:srs_q] = q
				end

=begin
				opts.on("--srs-q-fmt FORMAT", "a descriptor that specifies the format of the srs question cards. use $1, ..., $n to reference data from the select") do |fmt|
					options[:srs_q_fmt] = fmt
				end
				
				opts.on("--srs-a-fmt FORMAT", "a descriptor that specifies the format of the srs answer cards. use $1, ..., $n to reference data from the select") do |fmt|
					options[:srs_a_fmt] = fmt
				end
								

				opts.on("--interactive", "interactive mode. default: #{options[:interactive].inspect}") do |int|
					options[:interactive] = int
				end
=end
						
				opts.separator ""
				opts.separator "Common options:"
								
				opts.on("-h", "--help", "Show this message") do
					raise ShowOptionException.new, ""
				end
				
				opts.on("-v", "--verbose", "print debug messages") do
					options[:verbose] = true
				end
				
			end
									
			begin
				opts.parse!(args)
				
				raise OptionParser::InvalidOption.new("must supply a database") if options[:db].nil?
				
				if !options[:srs].nil?
					[:srs_q].each do |name|
						raise "must supply a #{name} for srs output" if options[name].nil?
					end
				end				
			rescue OptionParser::ParseError => e
				if !e.is_a?(ShowOptionException)
					puts exception_string(e, "", false) 
					puts options.inspect
				end
				
				puts opts
				
				exit
			end	
			return options
		end  # parse()

	end	  

	HEB_XML_PREFIX = "<deck>"
	HEB_XML_SUFFIX = "</deck>" 	
		
	def initialize(options)
		@options = options
		
	end

	def log(s)
		puts s
	end
			
	def run
		log "running with options: #{@options.inspect}"
		
		active_record_cx
		
		if !@options[:file].nil? && File.file?(@options[:file])
			cx = Mysql.new("localhost", @options[:db_user], @options[:db_pass])
			cx.query("DROP DATABASE IF EXISTS #{@options[:db]}") if !@options[:append]
			cx.query("CREATE DATABASE IF NOT EXISTS #{@options[:db]} DEFAULT CHARACTER SET = 'utf8'")
			cx.query("USE #{@options[:db]}")
			
			import_to_db("word_list", @options[:file])
		end
		
		if !@options[:srs].nil?
			generate_srs(@options[:srs], @options[:srs_q])
		end
	end

	def generate_srs(file, query)
		cx = ActiveRecord::Base.connection	
		
		log query
		
		File.open(file, "w") do |f|
			
			f << "<deck>\n\n"
			
			card_count = 1
			cx.execute(query).each do |tuple|
				#log tuple.inspect
				
				card = "\t<card>\n"
				
				q = question_fmt_a(tuple[0], tuple[1], tuple[2], tuple[3], tuple[4], tuple[5])
				
				#log q
				card += "\t\t<question hebrew=\"true\" latex=\"true\" equation=\"false\" size=\"16\"> #{q} </question>\n"
				
				a1 = answer_fmt_a1(tuple[0], tuple[1], tuple[2], tuple[3], tuple[4], tuple[5])
				
				#log a1
				card += "\t\t<answer hebrew=\"true\" latex=\"true\" equation=\"false\" size=\"16\"> #{a1} </answer>\n"
				
			 	a2 = answer_fmt_a2(tuple[0], tuple[1], tuple[2], tuple[3], tuple[4], tuple[5])
				card += "\t\t<answer size=\"16\"> #{a2} </answer>\n"
				
				card += "\t</card>\n\n"
				
				#puts card
				
				f << card
				print "wrote #{card_count}\r"
				$stdout.flush
			end
			
			f << "</deck>\n"
		end
		
		puts "wrote #{file}"
		
	end
	
	ADJECTIVE_TABLE = {"Masculine+Singular" => "טוב",
		"Masculine+Plural" => "טובים",
		"Feminine+Singular" => "טובה",
		"Feminine+Plural" => "טובות"
	}
	
	def question_fmt_a(word, trans, gender, plural, type, freq)
				
		return "#{word}"
	end
	
	def answer_fmt_a1(word, trans, gender, plural, type, freq)
		adj = ADJECTIVE_TABLE[gender + "+" + plural]
		
		return "#{word} #{adj}"
	end
	
	def answer_fmt_a2(word, trans, gender, plural, type, freq)
		return "#{trans}"
	end
	
	
=begin
	def interactive
		cmd = "mysql -u root #{@options[:db]}"
		#log cmd.inspect
		
		system(cmd)
		
		log "please enter a select query to select the data for output"
		query = readline.strip
		
		log query
		
	end
=end
			
	def active_record_cx
		ar_options = {:adapter  => "mysql",
			:host     => "127.0.0.1",
			:username => @options[:db_user],
			:password => @options[:db_pass],
			:database => @options[:db]
		}
		
		log "connect to AR with opts: #{ar_options.inspect}"
		pool = ActiveRecord::Base.establish_connection(ar_options)
		log "AR conn: #{pool.inspect}"
		
		return true
	end
	
	def import_to_db(table, file)
		
		cx = ActiveRecord::Base.connection
						
		File.open(file, "r") do |f|
			schema = f.readline.split("\t")
			log "schema: #{schema.inspect}"
			version = f.readline
			log "version: #{version.inspect}"
			raise "could not parse #{@options[:file].inspect}. invalid version line" if version.match(/^majorVersion:\s[\d\.]+?\sminorVersion:\s[\d\.]+?/).nil?

			real_schema = []
			if !cx.table_exists?(table)
				ActiveRecord::Base.transaction do
					cx.create_table(table) do |t|
						schema.each do |field|
							log "field: #{field}"
							if field.match(/^Reserved/)
								log "skip field: #{field}"
								next
							end
							
							t.column field, :text
							real_schema << field
						end
					
					end
				end
			end
			
			log "real schema: #{real_schema.inspect}"
			
			lines = 1			
			f.each_line do |l|
				word = l.split("\t")
				#log word.inspect
				
				raise "invalid word entry. number of columns (#{word.size}) did not match the schema (#{schema.size}): #{word.inspect}" if word.size != schema.size
				
				q = "INSERT INTO #{table} (#{real_schema.join(", ")}) VALUES (#{word[0..-3].collect {|x| cx.quote(x)}.join(", ")} )"

				#readline
				
				print "inserted line #{lines}\r"
				lines += 1
				
				$stdout.flush if lines % 20 == 0
				
				cx.execute(q)
			end
		end
	end
	
end
		
if $0 == __FILE__
	#puts ARGV.inspect
	
	options = FSListParser::FSListParserOpts::parse(ARGV)
	fsl = FSListParser.new(options)
	fsl.run
end
