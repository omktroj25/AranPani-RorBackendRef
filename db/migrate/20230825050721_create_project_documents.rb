class CreateProjectDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :project_documents do |t|
      t.references :project, null: false, foreign_key: true
      t.string :document_url

      t.timestamps
    end
  end
end
