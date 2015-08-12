# xenhost.rb

Facter.add('xenhost') do
  setcode do
    virtualtype = Facter.value(:virtual)
    if virtualtype == 'xenu' or virtualtype == 'xenhvm' or virtualtype == 'xen'
      Facter::Util::Resolution.exec('xenstore-read /tool/hostname')
    else
      'physical'
    end
  end
end