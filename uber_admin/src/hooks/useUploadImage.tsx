"use client";
import { userAtom } from "@/state";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import { useAtom } from "jotai";
import Storage from "@/local_repository/storage";


// todo add some systeme to delete unused images
export default function useUploadImage() {
    const [user] = useAtom(userAtom);

    return async (
        file: File,
        fileName: string,
        type: "seller/photo" | "deliver/photo" | "bag/photo"
    ) => {
        return new Promise<string>((resolve, reject) => {
            const extention = file.name.split(".").pop();
            const storageRef = ref(Storage, `${type}/${fileName}.${extention}`);

            console.log(extention, storageRef);
            uploadBytes(storageRef, file, {
                contentType: file.type,
                cacheControl: "public, max-age=31536000",
            })
                .then((snapshot) => {
                    // resolve google storage url
                    resolve(
                        `https://firebasestorage.googleapis.com/v0/b/${snapshot.ref.bucket
                        }/o/${encodeURIComponent(snapshot.ref.fullPath)}?alt=media`
                    );
                })
                .catch((error) => {
                    reject(error);
                });
        });
    };
}
