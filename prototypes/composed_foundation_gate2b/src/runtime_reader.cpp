#include <rapidjson/document.h>

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <string_view>

namespace {

int reject(const std::string_view detail) {
  std::cerr << "{\"code\":\"SAC-RUNTIME-MALFORMED-MAP-PACKAGE\",\"detail\":\""
            << detail << "\"}\n";
  return 2;
}

bool has_array(const rapidjson::Value& value, const char* name) {
  return value.HasMember(name) && value[name].IsArray();
}

}  // namespace

int main(const int argument_count, char** arguments) {
  if (argument_count != 2) {
    return reject("runtime reader expects one cooked package path");
  }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunsafe-buffer-usage"
  const char* package_path = arguments[1];
#pragma clang diagnostic pop
  std::ifstream package_stream(package_path, std::ios::binary);
  if (!package_stream) {
    return reject("cannot read cooked package");
  }
  const std::string bytes{
      std::istreambuf_iterator<char>{package_stream}, std::istreambuf_iterator<char>{}};
  rapidjson::Document package;
  package.Parse(bytes.c_str(), bytes.size());
  if (package.HasParseError() || !package.IsObject() ||
      !package.HasMember("format") || !package["format"].IsString() ||
      std::string_view{package["format"].GetString()} != "sacramento.map-package" ||
      !package.HasMember("version") || !package["version"].IsInt() ||
      package["version"].GetInt() != 1 || !package.HasMember("content") ||
      !package["content"].IsObject()) {
    return reject("unsupported cooked package");
  }

  const rapidjson::Value& content = package["content"];
  if (!content.HasMember("map_id") || !content["map_id"].IsString() ||
      !has_array(content, "anchors") || !has_array(content, "materials") ||
      !has_array(content, "meshes") || !has_array(content, "colliders")) {
    return reject("cooked package content is incomplete");
  }

  std::size_t vertex_count = 0;
  std::size_t index_count = 0;
  for (const rapidjson::Value& mesh : content["meshes"].GetArray()) {
    if (!mesh.IsObject() || !has_array(mesh, "positions") ||
        !has_array(mesh, "indices")) {
      return reject("cooked mesh is incomplete");
    }
    vertex_count += mesh["positions"].Size();
    index_count += mesh["indices"].Size();
  }
  if (index_count % 3U != 0U) {
    return reject("cooked mesh indices are not triangles");
  }

  std::cout << "{\"format\":\"sacramento.map-inspection\",\"version\":1,"
               "\"map_id\":\""
            << content["map_id"].GetString() << "\",\"anchor_count\":"
            << content["anchors"].Size() << ",\"material_count\":"
            << content["materials"].Size() << ",\"mesh_count\":"
            << content["meshes"].Size() << ",\"collider_count\":"
            << content["colliders"].Size() << ",\"vertex_count\":" << vertex_count
            << ",\"triangle_count\":" << index_count / 3U << "}\n";
  return EXIT_SUCCESS;
}
