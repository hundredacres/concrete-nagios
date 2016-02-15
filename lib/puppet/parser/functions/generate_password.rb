#Will generate a password args long from the fqdn (gonna call fqdn_rand to do it)
#Call is of the form generate_password( length, seed) where length is an integer representing the number of characters required, seed is a random seed.
#for example class name.

	module Puppet::Parser::Functions
		newfunction(:generate_password, :type => :rvalue) do |args|
			Puppet::Parser::Functions.autoloader.loadall
			length = args[0].to_i
			seed = args[1]
			charnumber = 0
			password = ""
			while charnumber < length do
				randchar = function_fqdn_rand( [ 26, seed + charnumber.to_s ] )
				#This is going to randomise whether its a capital or not.
				if function_fqdn_rand( [ 2, seed + (charnumber + length).to_s ] ).to_i == 1.to_i
					starting = 65
				else
					starting = 97
				end
				randchar = starting + randchar.to_i
				char = randchar.chr
				password = password + char
				charnumber = charnumber + 1
			end
		##return password
		password
		end
	end