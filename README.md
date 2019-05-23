# DrawAI with NVIDIA SPADE

DrawAI is an interactive deep learning project to explore content creation with GANs (general adversarial networks) and experiment with python webapps.  Users can convert quick drawings into photorealistic landscapes with AI based on NVIDIA's SPADE model.  Thanks to the code available on the [SPADE](https://github.com/NVlabs/SPADE), [smart-sketch](https://github.com/noyoshi/smart-sketch), and [drawingboard](https://github.com/Leimi/drawingboard.js/) githubs, implementation is straightforward through python, javascript, and html, with adjustments made in this repository for mobile users and deployment options.  

GANs, created in 2014 by [Ian Goodfellow et al](https://arxiv.org/pdf/1406.2661.pdf), are new advancements in neural networks that train two models in tandem, one *generating* random data with another *discriminating* against fake outputs.  Typically used in image synthesis, GANs have grown in popularity from headlines about deepfakes and [this person doesn’t exist](https://thispersondoesnotexist.com/).  NVIDIA’s SPADE (SPatially ADaptivE normalization for semantic image synthesis) effectively consolidates features of previous GAN releases under one model, powering tools like DrawAI and NVIDIA's upcoming [GauGAN](https://www.youtube.com/watch?v=MXWm6w4E5q0) while outperforming on key performance benchmarks (assuming full GPU support).

Host DrawAI locally on a PC or linux environment by following steps 1-3 below, or as a webapp in steps 4-12 using Google Cloud Platform (example at [dscil.xyz](dscil.xyz)). An appendix includes notes on VAE style training and similar GAN applications.

<br/>

### PC and Linux VM Setup (Localhost)

Minimum requirements:
- Linux (Debian/Ubuntu preferred)
- Python 3.5+ (with pip3)
- Modern CPU with 2GB+ ram
- (optional) Anaconda 4.6+

Draw AI runs on a pretrained SPADE model with *GPU support disabled* by default, keeping server costs low and minimizing dependencies.  However, users with CUDA-supported machines can enhance performance by enabling enable GPUs under `DrawAI > options > base options > line 25`.

<br/>

#### 1) Download DrawAI github repository

Install git:
```
sudo apt-get update
sudo apt-get install git
```

Download DrawAI repository:
```
git clone “https://github.com/scilley/drawAI”
```

Create subfolder for NVIDIA's pretrained SPADE model and navigate to folder:
```
cd drawAI
mkdir checkpoints
cd checkpoints
```

Download pretrained model [here]( https://drive.google.com/file/d/12gvlTbMvUcJewQlSEaZdeb2CdOB-b8kQ/view?usp=sharing), place in checkpoints folder, then unpack with:
```
tar xvf checkpoints.tar.gz
```
Note: DrawAI only uses the COCO file, other checkpoints can be deleted.

<br/>

#### 2) Install dependencies 

**A)** Preferred method with anaconda (a virtual environment and package manager):

Create virtual environment, navigate back to the drawAI folder, and install dependencies:
```
conda create --name drawAI pip
conda activate drawAI
cd ..
pip install -r requirements.txt 
```

Confirm installation:
```
conda list -n drawAI
```

Note: Close conda environments with `conda deactivate`.

**B)** Alternative without anaconda (for webapp setup to minimize storage needs):
```
cd drawAI
pip3 install -r requirements.txt
```
<br/>

#### 3) Run Draw AI

Initialize server with flask/tornado (runs on localhost port 8080):
```
python3 server.py
```

Using a web browser, navigate to:
```
0.0.0.0:8080
```

Note: Shut down the DrawAI python server by typing `ctrl+c`.

<br/>

### Webapp Setup on Google Cloud Platform (External IP)

Google currently offers a [free trial](cloud.google.com/freetrial) of Google Cloud Platform (GCP), but AWS, Azure, and others should function similarly.  

<br/>

#### 4) Create a new GCP *account,* *project,* and *service account* under `IAM & admin > service account`  
Service accounts handle security clearances for Google Cloud Platform (GCP) services, but default service accounts are temperamental.  Create a new service account with *storage admin* and *log writing* clearance.

<br/>

#### 5) Create a new *compute engine* 
- Region/zone: us-west1-b or [similar](https://cloud.google.com/compute/docs/regions-zones/)
- Machine type: n1-standard-1 (1 vCPU, 3.75GB memory)
- Boot disk: Debian GNU/Linux 9 (10GB storage)
- Identity and API access: use the custom service account from Step 4
- Allow HTTP and HTTPS traffic

<br/>

#### 6) Download DrawAI repository, SPADE pretrained model, and dependencies from Steps 1 and 2b

To import the [SPADE pretrained model](https://drive.google.com/file/d/12gvlTbMvUcJewQlSEaZdeb2CdOB-b8kQ/view?usp=sharing), upload to a GCP storage bucket under `Storage > storage`, attach the custom service account, and download with:
```
gsutil cp gs://[BUCKET_NAME]/[OBJECT_NAME] [OBJECT_DESTINATION]
```

<br/>

#### 7) Add firewall rules for port 8080 under `VPC network > firewall rules`
- Logs: off
- Network: default
- Priority: 1000
- Direction: ingress
- Action on match: allow
- Source filters: IP range 0.0.0.0/0
- Protocols and ports: TCP 8080

Note: Many GCP services look to port 8080 by default.

<br/>

#### 8) Test DrawAI 

In terminal, start the server:
```
python3 server.py
```

Navigate to the GCP Compute Engine page and access DrawAI as:
```
[external ip]:8080.
```

<br/>

#### 9) Install Docker CE 18.03.1 per [here](https://docs.docker.com/install/linux/docker-ce/debian/#install-from-a-package)
Certain GCP services are incompatible with Docker <18.03 or >18.1, more [here]( https://cloud.google.com/container-registry/docs/advanced-authentication).

May require libltdl7:
```
sudo apt-get update
sudo apt-get install libltdl7
```

May also require setting temporary user permissions, more [here]( https://techoverflow.net/2017/03/01/solving-docker-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket/).  Exit and restart terminal after running:
```
sudo usermod -a -G docker $USER
```

Confirm install with:
```bash
docker version
```

Initialize Docker with Gcloud
```bash
gcloud auth configure-docker
```

<br/>

#### 10) Upload image to Google Container Registry

Navigate to the DrawAI folder and run:
```bash
sh build.sh
```

The image should appear in GCP under `Tools > Container Registry`.  It may take several minutes.

<br/>

#### 11) Deploy to Google Cloud Run

In GCP, under `Compute > Cloud Run`, select *create service* at the top:
- Allow unauthenticated invocations
- Memory allocated: 2GB (this MUST be 2GB, otherwise the CPU will run out of memory when the SPADE deep learning model is called)

Note: the process can take several minutes.

<br/>

#### 12) Access DrawAI webapp
Last, use the link at the top of the Google Cloud Run webpage to use DrawAI!  This link can also be configured to host on an external domain (I followed their steps to host on my custom domain at dscil.xyz).

<br/>

#### Appendix: Training, Stylization, and Extended Applications of GANs

TBD
