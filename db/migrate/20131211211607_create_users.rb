class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_email
      t.string :access_token
      t.string :refresh_token

      t.timestamps
    end
  end
end
