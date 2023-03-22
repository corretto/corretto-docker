import json

DEFAULT_ALPINE_VERSION = '3.17'
ALPINE_VERSIONS = ['3.14', '3.15', '3.16', '3.17']

LTS_VERSIONS = [ "8", "11", "17"]

def generate_tags(key, version):
    update = version.split('.')[1] if (key == '8') else version.split('.')[2]
    expanded_version = f"{key}u{update}" if (key == '8') else f"{key}.0.{update}"

    al2_tags = [f"{key}", f"{expanded_version}", f"{expanded_version}-al2", f"{key}-al2-full",f"{key}-al2-jdk"]
    al2023_tags = [f"{key}-al2023-RC",  f"{expanded_version}-al2023-RC" ,f"{key}-al2023-jdk"]
    if key == '8':
        al2_tags.append('latest')


    print("Tags: " + ", ".join(al2_tags) + "")
    print("Architectures: amd64, arm64v8")
    print(f"Directory: {key}/jdk/al2\n")

    if key in LTS_VERSIONS:
        print("Tags: " + ", ".join(al2023_tags) + "")
        print("Architectures: amd64, arm64v8")
        print(f"Directory: {key}/jdk/al2023\n")
        if key == '8':
            print("Tags: " + ", ".join([f"{key}-al2023-RC-jre",  f"{expanded_version}-al2023-RC-jre"]))
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/jdk/al2023\n")
        else:
            print("Tags: " + ", ".join([f"{key}-al2023-RC-headless",  f"{expanded_version}-al2023-RC-headless"]))
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/headless/al2023\n")

            print("Tags: " + ", ".join([f"{key}-al2023-RC-headful",  f"{expanded_version}-al2023-RC-headful"]))
            print("Architectures: amd64, arm64v8")
            print(f"Directory: {key}/headful/al2023\n")

    for alpine_version in ALPINE_VERSIONS:
        alpine_tags = [f"{key}-alpine{alpine_version}", f"{expanded_version}-alpine{alpine_version}", f"{key}-alpine{alpine_version}-full", f"{key}-alpine{alpine_version}-jdk"]
        if alpine_version == DEFAULT_ALPINE_VERSION:
            alpine_tags.extend([f"{key}-alpine", f"{expanded_version}-alpine", f"{key}-alpine-full", f"{key}-alpine-jdk"])
        print("Tags: " + ", ".join(alpine_tags) + "")
        print("Architectures: amd64")
        print(f"Directory: {key}/jdk/alpine/{alpine_version}\n")
        if key == '8':
            alpine_jre_tags = [f"{key}-alpine{alpine_version}-jre", f"{expanded_version}-alpine{alpine_version}-jre"]
            if alpine_version == DEFAULT_ALPINE_VERSION:
                alpine_jre_tags.extend([f"{key}-alpine-jre", f"{expanded_version}-alpine-jre"])
            print("Tags: " + ", ".join(alpine_jre_tags) + "")
            print("Architectures: amd64")
            print(f"Directory: {key}/jre/alpine/{alpine_version}\n")


def main():
    with open('versions.json','r') as version_file:
        versions = json.load(version_file)

    with open('.tags', 'w') as tag_file:
        for key in versions:
            generate_tags(key, versions[key])

if __name__ == "__main__":
    main()