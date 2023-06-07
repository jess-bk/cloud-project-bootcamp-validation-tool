require 'time'
require 'json'

# Represents a Manifest for a set of payloads
class Cpbvt::Manifest
  # This class stores metadata and payloads data structures for a manifest.

  attr_accessor :payloads,  # Stores all the payloads data structures
                :user_uuid,  # The UUID of the user
                :run_uuid,   # The UUID of the run
                :output_path,  # The path to the output directory
                :project_scope,  # The scope of the project
                :starts_at,  # The start timestamp of the manifest
                :ends_at   # The end timestamp of the manifest

  # Initializes a new Manifest object
  #
  # @param user_uuid [String] The UUID of the user
  # @param run_uuid [String] The UUID of the run
  # @param output_path [String] The path to the output directory
  # @param project_scope [String] The scope of the project
  # @param payloads_bucket [String] The name of the payloads bucket
  def initialize(user_uuid:, run_uuid:, output_path:, project_scope:, payloads_bucket:)
    # This method initializes a new Manifest object with the given parameters.
    # It sets the start and end timestamps to the current time, and initializes the payloads as an empty hash.

    @starts_at = Time.now.to_i
    @user_uuid = user_uuid
    @run_uuid = run_uuid
    @project_scope = project_scope
    @output_path = output_path
    @payloads = {}
  end

  # Returns the path to the output manifest file
  #
  # @return [String] The path to the output manifest file
  def output_file
    # This method returns the path to the output manifest file based on the provided parameters.
    # The file path is constructed using the output path, project scope, user UUID, and run UUID.

    File.join(
      @output_path,
      @project_scope,
      "user-#{@user_uuid}",
      "run-#{@run_uuid}",
      "manifest.json"
    )
  end

  # Returns the S3 object key for the manifest file
  #
  # @return [String] The S3 object key for the manifest file
  def object_key
    # This method returns the S3 object key for the manifest file based on the provided parameters.
    # The object key is constructed using the project scope, user UUID, and run UUID.

    File.join(
      @project_scope,
      "user-#{@user_uuid}",
      "run-#{@run_uuid}",
      "manifest.json"
    )
  end

  # Adds a payload to the manifest
  #
  # @param key [String] The key identifying the payload
  # @param data [Object] The payload data
  def add_payload(key, data)
    # This method adds a payload to the manifest.
    # It takes a key to identify the payload and the corresponding data to be stored.

    @payloads[key] = data
  end

  def get_output key
    output_file = @payloads[key][:output_file]
    json_data = File.read(output_file)
    hash = JSON.parse(json_data)
    return hash
  end

  # Writes the manifest contents to a file
  def write_file
    # This method writes the contents of the manifest to a file.
    # The manifest contents are serialized as JSON and written to the output file.
    @ends_at = Time.now.to_i
    File.open(self.output_file, 'w') do |f|
      f.write(JSON.pretty_generate(self.contents))
    end
  end

  # Returns the contents of the manifest
  #
  # @return [Hash] The contents of the manifest
  def contents
    # This method returns the contents of the manifest as a hash.
    # It includes metadata such as user UUID, run UUID, project scope, benchmark timestamps,
    # and the payloads stored in the manifest.

    {
      metadata: {
        user_uuid: @user_uuid,
        run_uuid: @run_uuid,
        project_scope: @project_scope
      },
      benchmark: {
        starts_at: @starts_at,
        ends_at: @ends_at,
        duration_in_seconds: @ends_at - @starts_at
      },
      payloads: @payloads
    }
  end
end
