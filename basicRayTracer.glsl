// Author: Eric Knapik
// inhereitane and things, different object types
struct Sphere {
    float radius;
	vec3 pos;
};

// Global Object Definitions
Sphere sphere1 = Sphere(0.65, vec3(0.1, 1.0, -1.0));
Sphere sphere2 = Sphere(0.7, vec3(1.2, 1.4, 0.2));
    
// ----- Intersect Functions -----

// equation of plane dot((p - po), normal) = 0
// this assumes plane at y = 0 and normal is (0.0, 1.0, 0.0)
float iPlane(vec3 ro, vec3 rayDir) {
    return -ro.y/rayDir.y;
}

// Using a plane limited on the x axis to more closely mimic
// Turner Witter's paper
float iPlaneLimited(vec3 ro, vec3 rayDir) {
    float result = -ro.y/rayDir.y;
    vec3 pos = ro + result*rayDir;
    if(pos.x > 3.0 || pos.x < -5.0) {
        return -1.0;
    }
    return result;
}

vec3 nPlane() {
	return vec3(0.0, 1.0, 0.0);
}

float iSphere(vec3 ro, vec3 rayDir, Sphere sphere) {
	// solving the parametric sphere equation
    // solving the quadradic
    vec3 oc = ro - sphere.pos;
    float b = dot(oc, rayDir);
   	float c = dot(oc, oc) - sphere.radius*sphere.radius;
    float h = b*b - c;
    if( h < 0.0 ) return -1.0;
    float t = -b - sqrt(h);
    return t;
}

vec3 nSphere(vec3 pos, Sphere sphere) {
	return (pos - sphere.pos) / sphere.radius;
}


// returns the id of the object hit
// simultaneously sets the time that an object was hit
float intersect(in vec3 ro, in vec3 rayDir, out float resT) {
	resT = 10000.0; // infinity kinda
    float id = -1.0; // the object hit
    float tsphere1 = iSphere(ro, rayDir, sphere1);
    float tsphere2 = iSphere(ro, rayDir, sphere2);
    float tplane = iPlaneLimited(ro, rayDir);
    if(tsphere1 > 0.0) {
    	id = 2.0; // intersected with sphere1
        resT = tsphere1; // setting the time value the sphere is at
    }
    if(tsphere2 > 0.0 && tsphere2 < resT) {
    	id = 3.0;
        resT = tsphere2;
    }
    if(tplane > 0.0 && tplane < resT) {
    	id = 1.0;
        resT = tplane;
    }
    
    return id;
}


vec3 calColorRec(vec3 rayOr, vec3 rayDir) {
    float t;
    float id = intersect(rayOr, rayDir, t);
    
    vec3 pos = rayOr + rayDir*(t);
    // need this to prevent shelf shading
    vec3 posShadow = rayOr + rayDir*(t-0.0001);
    vec3 nor;
    vec3 reflectEye; // rayDir is the eye to position
    float time = 0.5*iGlobalTime;
    //vec3 lightPos = vec3(3.0*sin(time), 3.0, 3.0*cos(time));
    vec3 lightPos = vec3(1.5, 5.0, 6.0);
    vec3 lightDir = normalize(lightPos - pos);
    vec3 lightCol = vec3(1.0, 0.9, 0.7);
    float specCoeff, diffCoeff, ambCoeff;
    float spec, diff, shadow;
    vec3 amb;
    
    // set material of object
    vec3 material;
    if(id > 0.5 && id < 1.5) { // hit the plane
        nor = nPlane();
        reflectEye = reflect(normalize(rayDir), nor);
        // material color
        float tileSize = 2.0;
        float tile = mod(floor(tileSize*pos.x) + floor(tileSize*pos.z), 2.0);
        if(tile > 0.0) {
            material = vec3(0.9, 0.1, 0.1);
        } else {
            material = vec3(0.9, 0.9, 0.1);
        }
    } else if(id > 1.5 && id < 2.5) { // hit the sphere1
        nor = nSphere(pos, sphere1);
        reflectEye = reflect(normalize(rayDir), nor);
        // material color
    	material = vec3(0.8, 0.1, 0.3);
    } else if(id > 2.5 && id < 3.5) { // hit the sphere2
        nor = nSphere(pos, sphere2);
        reflectEye = reflect(normalize(rayDir), nor);
        // material color
        material = vec3(0.2, 0.1, 0.8);
    } else { // background
        // cornflower blue
    	return vec3(0.39, 0.61, 0.94);
    }

    // calculate lighting
    vec3 brdf;
    ambCoeff = 0.1;
    diffCoeff = 1.2;
    specCoeff = 1.0;
    // hard shadow method
    float trashTime; // this isn't going to be used right now
    shadow = intersect(posShadow, lightDir, trashTime);
    if(shadow > 0.0) {
        shadow = 0.1;
    } else {
    	shadow = 1.0;
    }
    amb = ambCoeff*vec3(1.0, 1.0, 1.0);
    diff = shadow*diffCoeff*clamp(dot(nor,lightDir), 0.0, 1.0);
    spec = shadow*specCoeff*pow(clamp(dot(reflectEye,lightDir), 0.0, 1.0), 30.0);
    brdf = material*lightCol*(diff+spec);
    brdf += amb;
    return brdf;
}


vec3 calColor(vec3 rayOr, vec3 rayDir) {
    float t;
    float id = intersect(rayOr, rayDir, t);
    
    vec3 pos = rayOr + rayDir*(t);
    // need this to prevent shelf shading
    vec3 posShadow = rayOr + rayDir*(t-0.0001);
    vec3 nor;
    vec3 reflectEye; // rayDir is the eye to position
    float time = 0.5*iGlobalTime;
    //vec3 lightPos = vec3(3.0*sin(time), 3.0, 3.0*cos(time));
    vec3 lightPos = vec3(1.5, 5.0, 6.0);
    vec3 lightDir = normalize(lightPos - pos);
    vec3 lightCol = vec3(1.0, 0.9, 0.7);
    float specCoeff, diffCoeff, ambCoeff;
    float spec, diff, shadow;
    vec3 amb;
    
    // set material of object
    vec3 material;
    if(id > 0.5 && id < 1.5) { // hit the plane
        nor = nPlane();
        reflectEye = reflect(normalize(rayDir), nor);
        // material color
        float tileSize = 2.0;
        float tile = mod(floor(tileSize*pos.x) + floor(tileSize*pos.z), 2.0);
        if(tile > 0.0) {
            material = vec3(0.9, 0.1, 0.1);
        } else {
            material = vec3(0.9, 0.9, 0.1);
        }
    } else if(id > 1.5 && id < 2.5) { // hit the sphere1
        nor = nSphere(pos, sphere1);
        reflectEye = reflect(normalize(rayDir), nor);
        // material color
        vec3 reflectRay = reflect(rayDir, nor);
        vec3 reflectColor = calColorRec(posShadow, reflectRay);
        // material color
        material = mix(vec3(.9), reflectColor, .7);
    } else if(id > 2.5 && id < 3.5) { // hit the sphere2
        nor = nSphere(pos, sphere2);
        reflectEye = reflect(normalize(rayDir), nor);
        // material color
        material = vec3(0.2, 0.1, 0.8);
    } else { // background
    	return vec3(0.39, 0.61, 0.94);
    }

    // calculate lighting
    vec3 brdf;
    ambCoeff = 0.1;
    diffCoeff = 1.2;
    specCoeff = 1.0;
    // hard shadow method
    float trashTime; // this isn't going to be used right now
    shadow = intersect(posShadow, lightDir, trashTime);
    if(shadow > 0.0) {
        shadow = 0.1;
    } else {
    	shadow = 1.0;
    }
    amb = ambCoeff*vec3(1.0, 1.0, 1.0);
    diff = shadow*diffCoeff*clamp(dot(nor,lightDir), 0.0, 1.0);
    spec = shadow*specCoeff*pow(clamp(dot(reflectEye,lightDir), 0.0, 1.0), 30.0);
    brdf = material*lightCol*(diff+spec);
    brdf += amb;
    return brdf;
}


// CAMERA SETTING
mat3 mkCamMat(in vec3 rayOrigin, in vec3 lookAtPoint, float roll) {
    vec3 cw = normalize(lookAtPoint - rayOrigin);
    vec3 cp = vec3(sin(roll), cos(roll), 0.0); //this is a temp right vec for cross determination
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));

    return mat3(cu, cv, cw);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*q;
    p.x *= iResolution.x / iResolution.y;
    
    // camera or eye (where rays start)
    // Straight ahead view
    vec3 rayOrigin = vec3(1.0, 1.1, 2.0);
    vec3 lookAtPoint = vec3(1.0, 1.1, -1.0);
    // top down view
    //vec3 rayOrigin = vec3(1.2, 6.4, 0.2);
    //vec3 lookAtPoint = vec3(1.2, -1.0, 0.3);
    float focalLen = 1.5; // how far camera is from image plane
    mat3 camMat = mkCamMat(rayOrigin, lookAtPoint, 0.0);

    // ray direction into image plane
    vec3 rayDir = camMat * normalize(vec3(p.xy, focalLen));
    
    //render the scene with ray marching
    vec3 col = calColor(rayOrigin, rayDir);
    fragColor = vec4(col, 1.0); 
	//fragColor = vec4(.9); // that off white
}
