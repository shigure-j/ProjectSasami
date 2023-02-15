# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Default work format
Format.delete_by name: :work
format = Format.new(name: :work)
format.format = %q({
    "name": {
        "type": "string",
        "option": ""
    },
    "project": {
        "type": "string",
        "option": ""
    },
    "design": {
        "type": "string",
        "option": ""
    },
    "stage": {
        "type": "string",
        "option": ""
    },
    "owner": {
        "type": "string",
        "option": ""
    },
    "relationship": {
        "title": "related",
        "type": "relationship",
        "option": ""
    },
    "path": {
        "type": "path",
        "option": ""
    },
    "created_at": {
        "title": "created",
        "type": "datetime",
        "option": "yyyy/MM/dd HH:mm"
    },
    "is_private": {
        "title": "private",
        "type": "boolean",
        "option": ""
    }
})
format.save
