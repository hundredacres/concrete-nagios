# used_blockdevices.rb

Facter.add('used_blockdevices') do
  setcode do
    blockdevices = Facter.value(:blockdevices)
    puts blockdevices
    used_blockdevices_array = Array.new
    blockdevices.each do |blockdevice|
      puts blockdevice
      if Facter::Util::Resolution.exec("/bin/df -h | /bin/grep #{blockdevice}") != ''
        used_blockdevices_array.push(blockdevice)
        puts blockdevice
      end
    end
    puts used_blockdevices = used_blockdevices_array.map {|element|
      "#{element}"
    }.join(',')
    used_blockdevices = used_blockdevices_array.map {|element|
      "#{element}"
    }.join(',')
  end
end