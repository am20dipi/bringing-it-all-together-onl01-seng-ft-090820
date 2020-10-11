class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(attribute_hash, id=nil)
    @name = attribute_hash[:name]
    @breed = attribute_hash[:breed]
    @id = attribute_hash[:id]
  end
  
  def self.create_table 
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs 
    SQL
    DB[:conn].execute(sql)
  end
  
  def save 
    if self.id 
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      
      row = DB[:conn].execute(sql, self.name, self.breed)
      last_row_id = DB[:conn].execute("SELECT * FROM dogs")[0][0]
      self.id = last_row_id
      self
    end
  end
  
  def self.create(attribute_hash)
    dog = self.new(attribute_hash)
    dog.save
    dog
  end
    
  
  def self.new_from_db(row)
    attribute_hash = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    self.new(attribute_hash)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1 
    SQL
    
    DB[:conn].execute(sql, id).collect do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1 
    SQL
    
    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed =?", name, breed).first
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new_from_db(dog)
    else
      dog = self.create({:name => name, :breed => breed})
    end
    dog
  end
  
  def update 
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end