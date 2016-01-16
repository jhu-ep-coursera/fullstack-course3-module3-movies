class Measurement
  attr_reader :amount, :units

  def initialize(amount, units=nil)
    @amount=amount
    @units = units
    #normalize
    case 
    when @units == "meters" then @amount=(@amount/0.3048); @units="feet"
    end
  end

  def to_s
    case
    when @amount && @units then "#{@amount} (#{@units})"
    when @amount && !@units then "#{@amount}"
    else nil
    end
  end

  #creates a DB-form of the instance
  def mongoize
    @units ? {:amount => @amount, :units => @units} : {:amount => @amount}
  end

  #creates an instance of the class from the DB-form of the data
  def self.demongoize(object)
    case object
    when Hash then Measurement.new(object[:amount], object[:units])
    else nil
    end
  end

  #takes in all forms of the object and produces a DB-friendly form
  def self.mongoize(object) 
    case object
    when Measurement then object.mongoize
    else object
    end
  end

  #used by criteria to convert object to DB-friendly form
  def self.evolve(object)
    case object
    when Measurement then object.mongoize
    else object
    end
  end
end
