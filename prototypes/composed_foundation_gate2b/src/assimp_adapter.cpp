#include <assimp/Importer.hpp>
#include <assimp/postprocess.h>
#include <assimp/scene.h>

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <limits>
#include <locale>
#include <sstream>
#include <string>
#include <string_view>

namespace {

void write_json_string(std::ostream& output, const std::string_view value) {
  output << '"';
  for (const char source_character : value) {
    const auto character = static_cast<unsigned char>(source_character);
    switch (character) {
      case '"': output << "\\\""; break;
      case '\\': output << "\\\\"; break;
      case '\b': output << "\\b"; break;
      case '\f': output << "\\f"; break;
      case '\n': output << "\\n"; break;
      case '\r': output << "\\r"; break;
      case '\t': output << "\\t"; break;
      default:
        if (character < 0x20U) {
          output << "\\u" << std::hex << std::setw(4) << std::setfill('0')
                 << static_cast<unsigned int>(character) << std::dec;
        } else {
          output << static_cast<char>(character);
        }
    }
  }
  output << '"';
}

void write_diagnostic(const std::string_view code, const std::string_view detail) {
  std::cerr << "{\"code\":";
  write_json_string(std::cerr, code);
  std::cerr << ",\"detail\":";
  write_json_string(std::cerr, detail);
  std::cerr << "}\n";
}

void write_node(std::ostream& output, const aiNode& node, bool& first) {
  if (!first) {
    output << ',';
  }
  first = false;
  output << "{\"name\":";
  write_json_string(output, node.mName.C_Str());
  output << ",\"translation\":[" << node.mTransformation.a4 << ','
         << node.mTransformation.b4 << ',' << node.mTransformation.c4 << "]}";
  for (unsigned int index = 0; index < node.mNumChildren; ++index) {
    write_node(output, *node.mChildren[index], first);
  }
}

const aiNode* find_mesh_node(const aiNode& node, const unsigned int mesh_index) {
  for (unsigned int index = 0; index < node.mNumMeshes; ++index) {
    if (node.mMeshes[index] == mesh_index) {
      return &node;
    }
  }
  for (unsigned int index = 0; index < node.mNumChildren; ++index) {
    if (const aiNode* result = find_mesh_node(*node.mChildren[index], mesh_index)) {
      return result;
    }
  }
  return nullptr;
}

void write_interchange(const aiScene& scene) {
  std::ostringstream output;
  output.imbue(std::locale::classic());
  output << std::setprecision(std::numeric_limits<float>::max_digits10);
  output << "{\"format\":\"sacramento.map-import\",\"version\":1,\"nodes\":[";
  bool first_node = true;
  write_node(output, *scene.mRootNode, first_node);
  output << "],\"materials\":[";
  for (unsigned int index = 0; index < scene.mNumMaterials; ++index) {
    if (index != 0U) {
      output << ',';
    }
    aiString name;
    scene.mMaterials[index]->Get(AI_MATKEY_NAME, name);
    output << "{\"name\":";
    write_json_string(output, name.C_Str());
    output << '}';
  }
  output << "],\"meshes\":[";
  for (unsigned int mesh_index = 0; mesh_index < scene.mNumMeshes; ++mesh_index) {
    if (mesh_index != 0U) {
      output << ',';
    }
    const aiMesh& mesh = *scene.mMeshes[mesh_index];
    const aiNode* node = find_mesh_node(*scene.mRootNode, mesh_index);
    output << "{\"source_node\":";
    write_json_string(output, node == nullptr ? "" : node->mName.C_Str());
    output << ",\"positions\":[";
    for (unsigned int vertex_index = 0; vertex_index < mesh.mNumVertices; ++vertex_index) {
      if (vertex_index != 0U) {
        output << ',';
      }
      const aiVector3D& vertex = mesh.mVertices[vertex_index];
      output << '[' << vertex.x << ',' << vertex.y << ',' << vertex.z << ']';
    }
    output << "],\"indices\":[";
    bool first_index = true;
    for (unsigned int face_index = 0; face_index < mesh.mNumFaces; ++face_index) {
      const aiFace& face = mesh.mFaces[face_index];
      for (unsigned int index = 0; index < face.mNumIndices; ++index) {
        if (!first_index) {
          output << ',';
        }
        first_index = false;
        output << face.mIndices[index];
      }
    }
    output << "]}";
  }
  output << "]}\n";
  std::cout << output.str();
}

}  // namespace

int main(const int argument_count, char** arguments) {
  if (argument_count != 2) {
    write_diagnostic("SAC-COOK-ADAPTER-USAGE", "native source adapter expects one source path");
    return EXIT_FAILURE;
  }

  Assimp::Importer importer;
  const aiScene* scene = importer.ReadFile(
      arguments[1], aiProcess_JoinIdenticalVertices | aiProcess_Triangulate |
                        aiProcess_SortByPType | aiProcess_ValidateDataStructure);
  if (scene == nullptr || scene->mRootNode == nullptr) {
    write_diagnostic("SAC-COOK-MALFORMED-SOURCE", "native importer rejected source");
    return 2;
  }
  write_interchange(*scene);
  return EXIT_SUCCESS;
}
