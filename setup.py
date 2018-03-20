from setuptools import setup

setup(
    name='Cash Bandicoot',
    version='0.1.0',
    long_description=__doc__,
    packages=['cashbandicoot'],
    include_package_data=True,
    zip_safe=False,
    install_requires=['Flask']
)
