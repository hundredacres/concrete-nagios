# lvm.rb

Facter.add('lvm') do
  setcode do
    virtualtype = Facter.value(:virtual)
    lvscan = Facter::Util::Resolution.exec('/sbin/lvscan 2>/dev/null | grep ACTIVE')
   if lvscan != "" and !lvscan.nil?
      true
    else
      false
    end
  end
end