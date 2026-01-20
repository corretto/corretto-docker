import jinja2
import json
import shutil
import os

def process_template_files(major_version, version, platform):
    templateLoader = jinja2.FileSystemLoader(searchpath="./templates/")
    templateEnv = jinja2.Environment(autoescape=jinja2.select_autoescape(['html', 'xml']), loader=templateLoader)

    template = templateEnv.get_template(f"{platform}.Dockerfile.template")
    template_slim = templateEnv.get_template(f"{platform}-slim.Dockerfile.template")
    input_parameter = {}
    input_parameter['CORRETTO_VERSION'] = version
    input_parameter['MAJOR_VERSION'] = major_version
    if platform == 'alpine':
        # Update .github/workflows/verify-images.yml as well when alpine versions changes
        os_versions = ['3.20', '3.21', '3.22', '3.23']
        slim_os_versions = os_versions[:-1]
    try:
        shutil.rmtree(f"{major_version}/jdk/{platform}")
        shutil.rmtree(f"{major_version}/jre/{platform}")
    except:
        pass
    for os_version in os_versions:
        input_parameter['OS_VERSION'] = os_version
        os.makedirs(f"{major_version}/jdk/{platform}/{os_version}/", exist_ok=True)
        with open(f"{major_version}/jdk/{platform}/{os_version}/Dockerfile", 'w') as output:
            output.write(template.render(**input_parameter))

        if major_version == '8':
            os.makedirs(f"{major_version}/jre/{platform}/{os_version}/", exist_ok=True)
            with open(f"{major_version}/jre/{platform}/{os_version}/Dockerfile", 'w') as output:
                output.write(template.render(**input_parameter, **{'jre':True}))

    # Alpine slim should be kept up to date on the latest OS version
    if platform == 'alpine':
        slim_path = f"{major_version}/slim/{platform}"
        if os.path.exists(slim_path):
            shutil.rmtree(slim_path)
            for os_version in slim_os_versions:
                os.makedirs(slim_path, exist_ok=True)
                with open(f"{slim_path}/Dockerfile", 'w') as output:
                    output.write(template_slim.render(**input_parameter))


def main():
    with open('versions.json','r') as version_file:
        versions = json.load(version_file)

    for key in versions:
        if "ALPINE" in versions[key]:
            process_template_files(key, versions[key]["ALPINE"], 'alpine')
        else:
            process_template_files(key, versions[key], 'alpine')


if __name__ == "__main__":
    main()
