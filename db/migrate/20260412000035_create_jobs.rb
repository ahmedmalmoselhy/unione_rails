class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.string :queue, null: false
      t.jsonb :payload, null: false
      t.integer :priority, null: false
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.string :concurrency_key

      t.timestamps
    end

    add_index :jobs, [:queue, :priority, :scheduled_at], name: 'index_jobs_for_fetching'
    add_index :jobs, :concurrency_key
  end
end
