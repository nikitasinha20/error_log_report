require "mysql2"
require "parallel"
require "active_support/time"


CLIENT = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "error_logs", :reconnect => true)
CLIENT.query("drop table IF EXISTS log_files")
CLIENT.query("create table log_files (request_id VARCHAR(20), timeStamp TIME, text LONGTEXT)")

# Singleton class to add tuples in the database from the files.
class ErrorLog
  attr_accessor :data
  
  def initialize
	@data = {}
  end
  
  def self.instance
	@@instance
  end
  
  def add (param)
    obj = param.split(" ");
    # considering only the first three values for request_id, timeStamp and text; ignoring other values if present
    request_id,timeStamp,text = obj[0],obj[1],obj[2]
    @data["request_id"] = request_id;
    @data["timeStamp"] = Time.at(timeStamp.to_i).strftime('%H:%M:%S');
    @data["text"] = text;
  end

  def add_in_db
    CLIENT.query("insert into log_files values ('#{@data["request_id"]}','#{@data["timeStamp"]}', '#{@data["text"]}')")
  end
  
  @@instance = ErrorLog.new
  
  private_class_method :new
end

# The file class deals with data in a file.
class FileData

  attr_accessor :data_rows
  
  def initialize(data)
    @data_rows = data.split("\n")
  end

  def add
    @data_rows.delete(@data_rows[0]) # delete the headings added in the array
    @data_rows.each do |row|
      log_inst = ErrorLog.instance
      log_inst.add(row)
      log_inst.add_in_db
    end
  end
    
end

# Utility module for processing the data 
module Process

  def self.read(file_name)
    f = File.read(file_name)
    file_data = FileData.new(f)
    file_data.add
  end
  
  def self.fetch_sorted_data(start_time, end_time)
    CLIENT.query("select text,count(text) as count 
                  from log_files 
                  where timeStamp between '#{start_time}' and '#{end_time}' 
                  group by text;").each(:as => :hash)
  end
  
  def self.create_time_range(x)
    time_range = Array.new()
    Date.today.to_datetime.step(Date.today.to_datetime + 1, 1.0/(24*60*60)){|d| time_range.push(d.strftime("%H:%M:%S"))}
    time_range = time_range.each_slice(x.minutes).collect(&:first).collect {|t| t}
    time_range
  end
  
  def self.process_data(time_range)
    results = Array.new()
    (0..time_range.size-2).to_a.each_with_index do |r,i|
      t = (Time.parse(time_range[i+1]).to_i) -1
      end_time = Time.at(t.to_i).strftime('%H:%M:%S')
      res = fetch_sorted_data(time_range[i],end_time)
      if res.size > 0
        results.push([[time_range[i].to_s + " - " +end_time.to_s, res]].to_h)
      end 
    end
    results
  end
  
  def self.print_result(results)
    puts "\nThe Error Analysis Report is as follows:\n\n"
    results.each do |result|
      puts "#{result.values.flatten[0]['text']}  #{result.keys[0]}  #{result.values.flatten[0]['count']}"
    end
  end
  
  def self.accept_input
    files = Array.new()
    print "Enter comma separated values of filename to be processed: "
    STDIN.gets.chomp.delete(" ").split(",").each do |f|
      if File.file?(f)
        files.push(f)
      end
    end
    print "Enter the number of files to be processed simultaneously: "
    n = STDIN.gets.chomp.to_i
    return files,n
  end

end

files,n = Process.accept_input

Parallel.map(files, in_processes: n) do |file|
  Process.read(file)
end

time_range = Process.create_time_range(15)
results = Process.process_data(time_range)
Process.print_result(results)

