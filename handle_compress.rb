class HandleCompress
  def compress_it(from, to)
    from_split = from.split("/")
    from_name = from_split.last
    from_path = from.gsub(from_name, "")
    `cd #{from_path} && /bin/tar -cJf #{to} #{from_name}`
  end

  def decompress_it(from, to, extract=false)
    to_split = to.split("/")
    to_name = to_split.last
    to_path = to.gsub(to_name, "")
    `/bin/tar -xJf #{from} -C #{to_path} #{to_name}`
    if extract == true
      begin
        f1 = File.read(to)
        return f1
      rescue Exception => e
        return nil
      end
    end
  end
end
