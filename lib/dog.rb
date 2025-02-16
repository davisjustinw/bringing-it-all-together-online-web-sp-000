class Dog
  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def save
    if @id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    end
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap do |dog|
      dog.save
    end
  end

  def self.new_from_db(row)

    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end


  def self.find_or_create_by(name:, breed:)
      sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
      row = DB[:conn].execute(sql, name, breed)

      if row.empty?
        self.create(name: name, breed: breed)
      else
        self.new_from_db(row.first)
      end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs
      (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

end
