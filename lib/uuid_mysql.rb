# Copyright (c) 2008 Intuit
# Written by Brian Morearty
# MIT License

class UUID

  BUCKET_SIZE = 5
  @@guid_bucket_mutex = Mutex.new
  @@guid_bucket = nil
  
  # We'll retrieve a bunch of guids at a time to reduce the # of DB round-trips.
  # If the guid bucket is empty, re-fill it by calling MySQL.  Then return a guid.
  def UUID.mysql_create(connection=ActiveRecord::Base.connection)
    raise "UUID.mysql_create only works with MySQL" unless connection.adapter_name.downcase =~ /mysql/
    @@guid_bucket_mutex.synchronize do
      if @@guid_bucket.blank?
        uuid_functions = Array.new(BUCKET_SIZE, "UUID()")
        sql = "SELECT #{uuid_functions.join(',')}"
        query = connection.execute(sql)
        if query.respond_to?(:fetch_row)
          @@guid_bucket = query.fetch_row
        else
          @@guid_bucket = query.to_a
        end
      end
      # My tests show shift is much faster than slice!(0), pop, or delete_at(0) 
      @@guid_bucket.shift
    end
  end

end
