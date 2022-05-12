import jinja2
import json
import shutil
import os

def process_template_files(major_version, version, platform):
    templateLoader = jinja2.FileSystemLoader(searchpath="./templates/")
    templateEnv = jinja2.Environment(autoescape=jinja2.select_autoescape(['html', 'xml']), loader=templateLoader)

    template = templateEnv.get_template(f"{platform}.Dockerfile.template")
    input_parameter = {}
    input_parameter['CORRETTO_VERSION'] = version
    input_parameter['MAJOR_VERSION'] = major_version
    if platform == 'alpine':
        # Update .github/workflows/verify-images.yml as well when alpine versions changes
        os_versions = ['3.13', '3.14', '3.15']
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

def main():
    with open('versions.json','r') as version_file:
        versions = json.load(version_file)
    
    for key in versions:
        process_template_files(key, versions[key], 'alpine')

if __name__ == "__main__":
    main()