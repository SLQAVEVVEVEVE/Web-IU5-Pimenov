class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.string :image_url
      t.string :material, null: false
      t.decimal :elasticity_gpa, precision: 6, scale: 2, null: false
      t.decimal :inertia_cm4, precision: 12, scale: 2, null: false
      t.integer :allowed_deflection_ratio, null: false, default: 250
      
      t.timestamps
      
      t.index :name, unique: true
      t.index :active
    end
    
    execute <<-SQL
      ALTER TABLE services 
      ADD CONSTRAINT check_material 
      CHECK (material IN ('wooden', 'steel', 'reinforced_concrete'));
      
      ALTER TABLE services 
      ADD CONSTRAINT check_elasticity_positive 
      CHECK (elasticity_gpa > 0);
      
      ALTER TABLE services 
      ADD CONSTRAINT check_inertia_positive 
      CHECK (inertia_cm4 > 0);
      
      ALTER TABLE services 
      ADD CONSTRAINT check_deflection_ratio_positive 
      CHECK (allowed_deflection_ratio > 0);
    SQL
  end
end
