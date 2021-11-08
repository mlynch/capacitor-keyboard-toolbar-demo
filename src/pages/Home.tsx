import {
  IonContent,
  IonHeader,
  IonPage,
  IonTextarea,
  IonTitle,
  IonToolbar,
} from "@ionic/react";
import { useCallback, useEffect, useRef } from "react";
import ExploreContainer from "../components/ExploreContainer";
import "./Home.css";

import { Plugins } from "@capacitor/core";

const Home: React.FC = () => {
  const editableRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const listener = Plugins.KeyboardToolbar.setup(({ button }: any) => {
      switch (button) {
        case "checkbox": {
          insertCheckbox();
          break;
        }
        case "bullet": {
          insertBullet();
          break;
        }
      }
    });

    return () => {
      listener();
    };
  }, []);

  const insertCheckbox = useCallback(() => {
    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    editableRef.current?.appendChild(checkbox);
  }, [editableRef.current]);

  const insertBullet = useCallback(() => {
    const item = document.createElement("li");
    editableRef.current?.appendChild(item);
  }, [editableRef.current]);

  const editableFocus = useCallback(() => {
    Plugins.KeyboardToolbar.enable();
    console.log("Editable focused");
  }, []);

  const editableBlur = useCallback(() => {
    Plugins.KeyboardToolbar.disable();
    console.log("Editable blurred");
  }, []);

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Blank</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Blank</IonTitle>
          </IonToolbar>
        </IonHeader>
        <div
          contentEditable={true}
          onFocus={editableFocus}
          onClick={editableFocus}
          onBlur={editableBlur}
          ref={editableRef}
          style={{
            color: "#fff",
            width: "100%",
            height: "300px",
            backgroundColor: "",
          }}
        />
      </IonContent>
    </IonPage>
  );
};

export default Home;
