# used_blockdevices.rb

Facter.add('used_blockdevices') do
  setcode do
    blockdevices = Facter.value(:blockdevices)
    used_blockdevices_array = Array.new
    blockdevice_array = blockdevices.split(',')
    blockdevice_array.each do |blockdevice|
      if Facter::Util::Resolution.exec("/bin/df -h | /bin/grep #{blockdevice}") != ''
        used_blockdevices_array.push(blockdevice)
      end
    end
    used_blockdevices = used_blockdevices_array.map {|element|
      "#{element}"
    }.join(',')
  end
end