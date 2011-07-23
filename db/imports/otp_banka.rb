require 'rails/all'
require 'digest/md5'

begin
  Fee.delete_all()

  lists = [
    {'file' => 'db/imports/a4.utf', 'month' => 1},
    {'file' => 'db/imports/a5.utf', 'month' => 2},
    {'file' => 'db/imports/a6.utf', 'month' => 3},
    {'file' => 'db/imports/a3.utf', 'month' => 4},
    {'file' => 'db/imports/a1.utf', 'month' => 5},
    {'file' => 'db/imports/a2.utf', 'month' => 6},
  ]

  #processing: db/imports/a3.utf : 4
  #| 20,00 | 2612906427/1100 | progressbar; VAJSOVÁ MARTINA
  #processing: db/imports/a4.utf : 1
  #| 40,00 | 2612906427/1100 | clenske dec+jan; VAJSOVÁ MARTINA
  #processing: db/imports/a5.utf : 2
  #0 | 20,00 | 2612906427/1100 | ...
  #0 | 20,00 | 2612906427/1100 | progressbar
  #22011 | 20,00 | 178266295/0900 | Adriana Danilakova
  #processing: db/imports/a6.utf : 3
  #| 20,00 | 2612906427/1100 | progressbar; VAJSOVÁ MARTINA
  #2011 | 20,00 | 178266295/0900 | Adriana Danilakova; Daniláková Adriána
  #| 40,00 | 2612906427/1100 | nerciss; VAJSOVÁ MARTINA
  #

  def parse_block(block)
    amount = 0
    month = 1
    currency = 'eur'
    year = 2011
    user_id = 0
    vs = 0
    msg = ''
    from_account = ''
    stamp = ''

    if block.match(/^[0-9]{0,2}\/([0-9]{0,2}) Platba/)
      l1 = block.match(/^[0-9]{0,2}\/([0-9]{0,2}) Platba[^0-9]+([0-9]+\/[0-9]+)\s+(\S+)\s*$/)
      l2 = block.match(/[0-9]*~0*([0-9]+)~/)
      l3 = block.match(/protiúčet: (.+)\n/)
      l4 = block.match(/Spr.: (.+)/)
      if l1 && l2
        month = l1[1]
        from_account = l1[2]
        amount = l1[3]
        vs = l2[1]

        msg = "#{l4[1].to_s}" if l4
        msg << "; #{l3[1]}" if l3

        user = User.where(:progressbar_uid => vs)
        stamp = Digest::MD5.hexdigest("#{month} #{year} #{amount} #{msg} #{user_id} #{l2[0]}")

        if !user.empty?
          f = Fee.new(:from_account => from_account,
            :message => msg,
            :vs => vs,
            :amount => amount,
            :currency => currency,
            :month => month,
            :year => year,
            :user_id => user.first.id,
            :stamp => stamp)

          if !f.valid?
            puts "#{vs.to_s} | #{user.first.username.to_s} | #{amount.to_s} | #{from_account.to_s} | #{msg.to_s} | #{f.errors.to_s}"
          end
        else
            puts "user not found: #{month} - #{vs.to_s}  | #{amount.to_s} | #{from_account.to_s} | #{msg.to_s}"
        end
      end
    end
  end

  def import_fees_from_file(f, m)
    fo = File.open(f, 'r').read
    
    blocks = fo.split('----------------------------------------------------------------------------')

    blocks.each do |block|
      parse_block(block.strip!)
    end

  end

  lists.each do |list|
    puts "processing: #{list['file']} : #{list['month']}"
    import_fees_from_file(list['file'], list['month'])
  end

  #rescue NameError
  #  puts 'name err'
end